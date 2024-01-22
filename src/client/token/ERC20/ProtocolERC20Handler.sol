// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/client/token/data/Fees.sol";
import "src/client/token/ProtocolHandlerCommon.sol";
import {IZeroAddressError, IAssetHandlerErrors} from "src/common/IErrors.sol";
import "../ProtocolHandlerTradingRulesCommon.sol";

/**
 * @title Example ApplicationERC20Handler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all rule checks related to the the ERC20 that implements it.
 * @notice Any rules may be updated by modifying this contract, redeploying, and pointing the ERC20 to the new version.
 */
contract ProtocolERC20Handler is Ownable, ProtocolHandlerCommon, ProtocolHandlerTradingRulesCommon, IProtocolTokenHandler, IAdminWithdrawalRuleCapable, ERC165 {
    using ERC165Checker for address;

    /// Data contracts
    Fees fees;
    bool feeActive;
    
    /// Rule mappings
    mapping(ActionTypes => Rule) minTransfer;
    mapping(ActionTypes => Rule) minMaxBalance;   
    mapping(ActionTypes => Rule) adminWithdrawal;  
    mapping(ActionTypes => Rule) tokenTransferVolume;
    mapping(ActionTypes => Rule) totalSupplyVolatility;
    /// Oracle rule mapping(allows multiple rules per action)
    mapping(ActionTypes => Rule[]) oracle;
    /// RuleIds for implemented tagged rules of the ERC721
    Rule[] private oracleRules;

    /**
     * @dev Constructor sets params
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     * @param _assetAddress address of the controlling asset.
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode) {
        if (_appManagerAddress == address(0) || _ruleProcessorProxyAddress == address(0) || _assetAddress == address(0)) 
            revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);

        transferOwnership(_assetAddress);
        if (!_upgradeMode) {
            deployDataContract();
            emit HandlerDeployed(_appManagerAddress);
        } else {
            emit HandlerDeployed(_appManagerAddress);
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IAdminWithdrawalRuleCapable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _sender the address triggering the contract action
     * @param _amount number of tokens transferred
     * @return true if all checks pass
     */
    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, address _sender, uint256 _amount)external override onlyOwner returns (bool) {
        bool isFromBypassAccount = appManager.isRuleBypassAccount(_from);
        bool isToBypassAccount = appManager.isRuleBypassAccount(_to);
        ActionTypes action = determineTransferAction(_from, _to, _sender);
        // // All transfers to treasury account are allowed
        if (!appManager.isTreasury(_to)) {
            /// standard rules do not apply when either to or from is an admin
            if (!isFromBypassAccount && !isToBypassAccount) {
                /// appManager requires uint16 _nftValuationLimit and uin256 _tokenId for NFT pricing, 0 is passed for fungible token pricing
                appManager.checkApplicationRules(address(msg.sender), _from, _to, _amount,  0, 0, action, HandlerTypes.ERC20HANDLER); 
                _checkTaggedAndTradingRules(balanceFrom, balanceTo, _from, _to, _amount, action);
                _checkNonTaggedRules(_from, _to, _amount, action);
            } else if (adminWithdrawal[action].active && isFromBypassAccount) {
                ruleProcessor.checkAdminWithdrawalRule(adminWithdrawal[action].ruleId, balanceFrom, _amount);
                emit RulesBypassedViaRuleBypassAccount(address(msg.sender), appManagerAddress); 
            }
            
        }
        /// If all rule checks pass, return true
        return true;
    }

    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) internal {
        if (minTransfer[action].active) ruleProcessor.checkMinTransferPasses(minTransfer[action].ruleId, _amount);

        for (uint256 oracleRuleIndex; oracleRuleIndex < oracle[action].length; ) {
            if (oracle[action][oracleRuleIndex].active) ruleProcessor.checkOraclePasses(oracle[action][oracleRuleIndex].ruleId, _to);
            unchecked {
                ++oracleRuleIndex;
            }
        }
        if (tokenTransferVolume[action].active) {
            transferVolume = ruleProcessor.checkTokenTransferVolumePasses(tokenTransferVolume[action].ruleId, transferVolume, IToken(msg.sender).totalSupply(), _amount, lastTransferTs);
            lastTransferTs = uint64(block.timestamp);
        }
        /// rule requires ruleID and either to or from address be zero address (mint/burn)
        if (totalSupplyVolatility[action].active && (_from == address(0x00) || _to == address(0x00))) {
            (volumeTotalForPeriod, totalSupplyForPeriod) = ruleProcessor.checkTotalSupplyVolatilityPasses(
                totalSupplyVolatility[action].ruleId,
                volumeTotalForPeriod,
                totalSupplyForPeriod,
                IToken(msg.sender).totalSupply(),
                _to == address(0x00) ? int(_amount) * -1 : int(_amount),
                lastSupplyUpdateTime
            );
            lastSupplyUpdateTime = uint64(block.timestamp);
        }
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTaggedAndTradingRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) internal {
        _checkTaggedIndividualRules(_balanceFrom, _balanceTo, _from, _to, _amount, action);
    }

    /**
     * @dev This function consolidates all the tagged rules that utilize account tags plus all trading rules.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTaggedIndividualRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) internal {
        bytes32[] memory toTags;
        bytes32[] memory fromTags;
        bool mustCheckPurchaseRules = action == ActionTypes.PURCHASE && !appManager.isTradingRuleBypasser(_to);
        bool mustCheckSellRules = action == ActionTypes.SELL && !appManager.isTradingRuleBypasser(_from);
        if ( minMaxBalance[action].active || 
            (mustCheckPurchaseRules && purchaseLimitRuleActive) ||
            (mustCheckSellRules && sellLimitRuleActive)
        )
        {
            // We get all tags for sender and recipient
            toTags = appManager.getAllTags(_to);
            fromTags = appManager.getAllTags(_from);
        }
        if (minMaxBalance[action].active) 
            ruleProcessor.checkMinMaxAccountBalancePasses(minMaxBalance[action].ruleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
        if((mustCheckPurchaseRules && (purchaseLimitRuleActive || purchasePercentageRuleActive)) || 
            (mustCheckSellRules && (sellLimitRuleActive || sellPercentageRuleActive))
        )
            _checkTradingRules(_from, _to, fromTags, toTags, _amount, action);
    }

    /* <><><><><><><><><><><> Fee functions <><><><><><><><><><><><><><> */
    /**
     * @dev This function adds a fee to the token
     * @param _tag meta data tag for fee
     * @param _minBalance minimum balance for fee application
     * @param _maxBalance maximum balance for fee application
     * @param _feePercentage fee percentage to assess
     * @param _targetAccount target for the fee proceeds
     */
    function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount) external ruleAdministratorOnly(appManagerAddress) {
        fees.addFee(_tag, _minBalance, _maxBalance, _feePercentage, _targetAccount);
        feeActive = true;
    }

    /**
     * @dev This function removes a fee to the token
     * @param _tag meta data tag for fee
     */
    function removeFee(bytes32 _tag) external ruleAdministratorOnly(appManagerAddress) {
        fees.removeFee(_tag);
    }

    /**
     * @dev returns the full mapping of fees
     * @param _tag meta data tag for fee
     * @return fee struct containing fee data
     */
    function getFee(bytes32 _tag) external view returns (Fees.Fee memory) {
        return fees.getFee(_tag);
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeTotal total number of fees
     */
    function getFeeTotal() public view returns (uint256) {
        return fees.getFeeTotal();
    }

    /**
     * @dev Turn fees on/off
     * @param on_off value for fee status
     */
    function setFeeActivation(bool on_off) external ruleAdministratorOnly(appManagerAddress) {
        feeActive = on_off;
        emit FeeActivationSet(on_off);
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeActive fee activation status
     */
    function isFeeActive() external view returns (bool) {
        return feeActive;
    }

    /**
     * @dev Get all the fees/discounts for the transaction. This is assessed and returned as two separate arrays. This was necessary because the fees may go to
     * different target accounts. Since struct arrays cannot be function parameters for external functions, two separate arrays must be used.
     * @param _from originating address
     * @param _balanceFrom Token balance of the sender address
     * @return feeCollectorAccounts list of where the fees are sent
     * @return feePercentages list of all applicable fees/discounts
     */
    function getApplicableFees(address _from, uint256 _balanceFrom) public view returns (address[] memory feeCollectorAccounts, int24[] memory feePercentages) {
        Fees.Fee memory fee;
        bytes32[] memory fromTags = appManager.getAllTags(_from);
        bytes32[] memory _fromTags;
        int24 totalFeePercent;
        uint24 discount;
        /// To insure that default fees are checked when they're set, add a blank tag to the tag list. 
        if(fees.getFee(BLANK_TAG).feePercentage > 0){
            _fromTags = new bytes32[](fromTags.length+1);
            for (uint i; i < fromTags.length; ) {
                _fromTags[i] = fromTags[i];
                unchecked {
                    ++i;
                }
            }
            _fromTags[_fromTags.length-1] = BLANK_TAG;
        } else {
            _fromTags = fromTags;
        }
        if (_fromTags.length != 0 && !appManager.isAppAdministrator(_from)) {
            uint feeCount;
            // size the dynamic arrays by maximum possible fees
            feeCollectorAccounts = new address[](_fromTags.length);
            feePercentages = new int24[](_fromTags.length);
            /// loop through and accumulate the fee percentages based on tags
            for (uint i; i < _fromTags.length; ) {
                fee = fees.getFee(_fromTags[i]);
                // fee must be active and the initiating account must have an acceptable balance
                if (fee.feePercentage != 0 && _balanceFrom < fee.maxBalance && _balanceFrom > fee.minBalance) {
                    // if it's a discount, accumulate it for distribution among all applicable fees
                    if (fee.feePercentage < 0) {
                        discount = uint24((fee.feePercentage * -1)) + discount; // convert to uint
                    } else {
                        feePercentages[feeCount] = fee.feePercentage;
                        feeCollectorAccounts[feeCount] = fee.feeCollectorAccount;
                        // add to the total fee percentage
                        totalFeePercent += fee.feePercentage;
                        unchecked {
                            ++feeCount;
                        }
                    }
                }
                unchecked {
                    ++i;
                }
            }
            /// if an applicable discount(s) was found, then distribute it among all the fees
            if (discount > 0 && feeCount != 0) {
                // if there are fees to discount then do so
                uint24 discountSlice = ((discount * 100) / (uint24(feeCount))) / 100;
                for (uint i; i < feeCount; ) {
                    // if discount is greater than fee, then set to zero
                    if (int24(discountSlice) > feePercentages[i]) {
                        feePercentages[i] = 0;
                    } else {
                        feePercentages[i] -= int24(discountSlice);
                    }
                    unchecked {
                        ++i;
                    }
                }
            }
        }
        // if the total fees - discounts is greater than 100 percent, revert
        if (totalFeePercent - int24(discount) > 10000) {
            revert FeesAreGreaterThanTransactionAmount(_from);
        }
        return (feeCollectorAccounts, feePercentages);
    }

    /// Rule Setters and Getters
    /**
     * @dev Set the minMaxBalanceRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinMaxAccountBalance(_ruleId);
        for (uint i; i < _actions.length; ) {
            minMaxBalance[_actions[i]].ruleId = _ruleId;
            minMaxBalance[_actions[i]].active = true;            
            emit ApplicationHandlerActionApplied(MIN_MAX_BALANCE_LIMIT, _actions[i], _ruleId);
            unchecked {
                        ++i;
             }
        }            
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            minMaxBalance[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(MIN_MAX_BALANCE_LIMIT, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(MIN_MAX_BALANCE_LIMIT, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * Get the minMaxBalanceRuleId.
     * @param _action the action type
     * @return minMaxBalance rule id.
     */
    function getMinMaxBalanceRuleId(ActionTypes _action) external view returns (uint32) {
        return minMaxBalance[_action].ruleId;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isMinMaxBalanceActive(ActionTypes _action) external view returns (bool) {
        return minMaxBalance[_action].active;
    }

    /**
     * @dev Set the minTransferRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setMinTransferRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            ruleProcessor.validateMinTransfer(_ruleId);
            minTransfer[_actions[i]].ruleId = _ruleId;
            minTransfer[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(MIN_TRANSFER, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action type
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransferRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            minTransfer[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(MIN_TRANSFER, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(MIN_TRANSFER, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Retrieve the minTransferRuleId
     * @param _action the action type
     * @return minTransferRuleId
     */
    function getMinTransferRuleId(ActionTypes _action) external view returns (uint32) {
        return minTransfer[_action].ruleId;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isMinTransferActive(ActionTypes _action) external view returns (bool) {
        return minTransfer[_action].active;
    }

    /**
     * @dev Set the oracleRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setOracleRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateOracle(_ruleId);
        for (uint i; i < _actions.length; ) {
            if (oracle[_actions[i]].length >= MAX_ORACLE_RULES) {
                revert OracleRulesPerAssetLimitReached();
            }

            Rule memory newEntity;
            newEntity.ruleId = _ruleId;
            newEntity.active = true;
            oracle[_actions[i]].push(newEntity);
            emit ApplicationHandlerActionApplied(ORACLE, _actions[i], _ruleId);
            unchecked {
                        ++i;
            }
        }
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     * @param ruleId the id of the rule to activate/deactivate
     */

    function activateOracleRule(ActionTypes[] calldata _actions, bool _on, uint32 ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            
            for (uint256 oracleRuleIndex; oracleRuleIndex < oracle[_actions[i]].length; ) {
                if (oracle[_actions[i]][oracleRuleIndex].ruleId == ruleId) {
                    oracle[_actions[i]][oracleRuleIndex].active = _on;

                    if (_on) {
                        emit ApplicationHandlerActionActivated(ORACLE, _actions[i]);
                    } else {
                        emit ApplicationHandlerActionDeactivated(ORACLE, _actions[i]);
                    }
                }
                unchecked {
                    ++oracleRuleIndex;
                }
            }
            unchecked {
                    ++i;
            }
        }
    }

    /**
     * @dev Retrieve the oracle rule id
     * @param _action the action type
     * @return oracleRuleId
     */
    function getOracleRuleIds(ActionTypes _action) external view returns (uint32[] memory ) {
        uint32[] memory ruleIds = new uint32[](oracle[_action].length);
        for (uint256 oracleRuleIndex; oracleRuleIndex < oracle[_action].length; ) {
            ruleIds[oracleRuleIndex] = oracle[_action][oracleRuleIndex].ruleId;
            unchecked {
                ++oracleRuleIndex;
            }
        }
        return ruleIds;
    }

    /**
     * @dev Tells you if the Oracle Rule is active or not.
     * @param _action the action type
     * @param ruleId the id of the rule to check
     * @return boolean representing if the rule is active
     */
    function isOracleActive(ActionTypes _action, uint32 ruleId) external view returns (bool) {
        for (uint256 oracleRuleIndex; oracleRuleIndex < oracle[_action].length; ) {
            if (oracle[_action][oracleRuleIndex].ruleId == ruleId) {
                return oracle[_action][oracleRuleIndex].active;
            }
            unchecked {
                ++oracleRuleIndex;
            }
        }
        return false;
    }

    /**
     * @dev Removes an oracle rule from the list.
     * @param _actions the action types
     * @param ruleId the id of the rule to remove
     */
    function removeOracleRule(ActionTypes[] calldata _actions, uint32 ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            Rule memory lastId = oracle[_actions[i]][oracle[_actions[i]].length -1];
            if(ruleId != lastId.ruleId){
                uint index = 0;
                for (uint256 oracleRuleIndex; oracleRuleIndex < oracle[_actions[i]].length; ) {
                    if (oracle[_actions[i]][oracleRuleIndex].ruleId == ruleId) {
                        index = oracleRuleIndex; 
                        break;
                    }
                    unchecked {
                        ++oracleRuleIndex;
                    }
                }
                oracle[_actions[i]][index] = lastId;
            }

            oracle[_actions[i]].pop();
            unchecked {
                        ++i;
            }
        }
    }

    /**
     * @dev Set the AdminWithdrawalRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setAdminWithdrawalRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAdminWithdrawal(_ruleId);
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (isAdminWithdrawalActiveForAnyAction()) {
            if (isAdminWithdrawalActiveAndApplicable()) revert AdminWithdrawalRuleisActive();
        }
        for (uint i; i < _actions.length; ) {
            /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
            adminWithdrawal[_actions[i]].ruleId = _ruleId;
            adminWithdrawal[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(ADMIN_WITHDRAWAL, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev This function is used by the app manager to determine if the AdminWithdrawal rule is active for any actions
     * @return Success equals true if all checks pass
     */
    function isAdminWithdrawalActiveAndApplicable() public view override returns (bool) {
        bool active;
        uint8 action = 0;
        /// if the rule is active for any actions, set it as active and applicable.
        while (action <= LAST_POSSIBLE_ACTION) { 
            if (adminWithdrawal[ActionTypes(action)].active) {
                try ruleProcessor.checkAdminWithdrawalRule(adminWithdrawal[ActionTypes(action)].ruleId, 1, 1) {} catch {
                    active = true;
                    break;
                }
            }
            action++;
        }
        return active;
    }

    /**
     * @dev This function is used internally to check if the admin withdrawal is active for any actions
     * @return Success equals true if all checks pass
     */
    function isAdminWithdrawalActiveForAnyAction() internal view returns (bool) {
        bool active;
        uint8 action = 0;
        /// if the rule is active for any actions, set it as active and applicable.
        while (action <= LAST_POSSIBLE_ACTION) { 
            if (adminWithdrawal[ActionTypes(action)].active) {
                active = true;
                break;
            }
            action++;
        }
        return active;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action type
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAdminWithdrawalRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            if (isAdminWithdrawalActiveAndApplicable()) revert AdminWithdrawalRuleisActive();
        }
        for (uint i; i < _actions.length; ) {
            adminWithdrawal[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(ADMIN_WITHDRAWAL, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(ADMIN_WITHDRAWAL, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the admin withdrawal rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isAdminWithdrawalActive(ActionTypes _action) external view returns (bool) {
        return adminWithdrawal[_action].active;
    }

    /**
     * @dev Retrieve the admin withdrawal rule id
     * @param _action the action type
     * @return adminWithdrawalRuleId rule id
     */
    function getAdminWithdrawalRuleId(ActionTypes _action) external view returns (uint32) {
        return adminWithdrawal[_action].ruleId;
    }

    /**
     * @dev Retrieve the token transfer volume rule id
     * @param _action the action type
     * @return tokenTransferVolumeRuleId rule id
     */
    function getTokenTransferVolumeRule(ActionTypes _action) external view returns (uint32) {
        return tokenTransferVolume[_action].ruleId;
    }

    /**
     * @dev Set the tokenTransferVolumeRuleId. Restricted to game admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setTokenTransferVolumeRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            ruleProcessor.validateTokenTransferVolume(_ruleId);
            tokenTransferVolume[_actions[i]].ruleId = _ruleId;
            tokenTransferVolume[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(TRANSFER_VOLUME, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the token transfer volume rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenTransferVolumeRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            tokenTransferVolume[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TRANSFER_VOLUME, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TRANSFER_VOLUME, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the token transfer volume rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenTransferVolumeActive(ActionTypes _action) external view returns (bool) {
        return tokenTransferVolume[_action].active;
    }

    /**
     * @dev Retrieve the total supply volatility rule id
     * @param _action the action type
     * @return totalSupplyVolatilityRuleId rule id
     */
    function getTotalSupplyVolatilityRule(ActionTypes _action) external view returns (uint32) {
        return totalSupplyVolatility[_action].ruleId;
    }

    /**
     * @dev Set the tokenTransferVolumeRuleId. Restricted to game admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setTotalSupplyVolatilityRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            ruleProcessor.validateSupplyVolatility(_ruleId);
            totalSupplyVolatility[_actions[i]].ruleId = _ruleId;
            totalSupplyVolatility[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(SUPPLY_VOLATILITY, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the token total Supply Volatility rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTotalSupplyVolatilityRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            totalSupplyVolatility[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(SUPPLY_VOLATILITY, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(SUPPLY_VOLATILITY, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the Total Supply Volatility is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTotalSupplyVolatilityActive(ActionTypes _action) external view returns (bool) {
        return totalSupplyVolatility[_action].active;
    }

    /**
     *@dev this function gets the total supply of the address.
     *@param _token address of the token to call totalSupply() of.
     */
    function getTotalSupply(address _token) internal view returns (uint256) {
        return IERC20(_token).totalSupply();
    }


    /// -------------DATA CONTRACT DEPLOYMENT---------------
    /**
     * @dev Deploy all the child data contracts. Only called internally from the constructor.
     */
    function deployDataContract() private {
        fees = new Fees();
    }

    /**
     * @dev Getter for the fee rules data contract address
     * @return feesDataAddress
     */
    function getFeesDataAddress() external view returns (address) {
        return address(fees);
    }

    /**
     * @dev This function is used to propose the new owner for data contracts.
     * @param _newOwner address of the new AppManager
     */
    function proposeDataContractMigration(address _newOwner) external appAdministratorOrOwnerOnly(appManagerAddress) {
        fees.proposeOwner(_newOwner);
    }

    /**
     * @dev This function is used to confirm this contract as the new owner for data contracts.
     */
    function confirmDataContractMigration(address _oldHandlerAddress) external appAdministratorOrOwnerOnly(appManagerAddress) {
        ProtocolERC20Handler oldHandler = ProtocolERC20Handler(_oldHandlerAddress);
        fees = Fees(oldHandler.getFeesDataAddress());
        fees.confirmOwner();
    }
}
