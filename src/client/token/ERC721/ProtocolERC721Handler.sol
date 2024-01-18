// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../ProtocolHandlerCommon.sol";
import "../ProtocolHandlerTradingRulesCommon.sol";

/**
 * @title Base NFT Handler Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract performs all rule checks related to the the ERC721 that implements it.
 *      Any rule handlers may be updated by modifying this contract, redeploying, and pointing the ERC721 to the new version.
 * @notice This contract is the interaction point for the application ecosystem to the protocol
 */

contract ProtocolERC721Handler is Ownable, ProtocolHandlerCommon, ProtocolHandlerTradingRulesCommon, IProtocolTokenHandler, IAdminWithdrawalRuleCapable, ERC165 {
    
    address public erc721Address;
    
    struct RuleMinimumHoldTime{
        uint32 ruleId;
        bool active;
        uint32 minimumHoldTimeHours;
    }
    /// Rule mappings
    mapping(ActionTypes => Rule) minMaxBalance;   
    mapping(ActionTypes => Rule) adminWithdrawal;  
    mapping(ActionTypes => Rule) minBalByDate; 
    mapping(ActionTypes => Rule) tokenTransferVolume;
    mapping(ActionTypes => Rule) totalSupplyVolatility;
    mapping(ActionTypes => Rule) minAccount;
    mapping(ActionTypes => Rule) tradeCounter;

    /// Oracle rule mapping(allows multiple rules per action)
    mapping(ActionTypes => Rule[]) oracle;
    /// RuleIds for implemented tagged rules of the ERC721
    Rule[] private oracleRules;

    /// Simple Rule Mapping
    mapping(ActionTypes => RuleMinimumHoldTime) minimumHoldTime;


    /// NFT Collection Valuation Limit
    uint16 private nftValuationLimit = 100;

    /// Trade Counter data
    // map the tokenId of this NFT to the number of trades in the period
    mapping(uint256 => uint256) tradesInPeriod;
    // map the tokenId of this NFT to the last transaction timestamp
    mapping(uint256 => uint64) lastTxDate;

    /// Minimum Hold time data
    mapping(uint256 => uint256) ownershipStart;
    /// Max Hold time hours
    uint16 constant MAX_HOLD_TIME_HOURS = 43830;

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _ruleProcessorProxyAddress of token rule router proxy
     * @param _appManagerAddress Address of App Manager
     * @param _assetAddress Address of the controlling address
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode) {
        if (_appManagerAddress == address(0) || _ruleProcessorProxyAddress == address(0) || _assetAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);

        transferOwnership(_assetAddress);
        setERC721Address(_assetAddress);
        if (!_upgradeMode) {
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
     * @dev This function is the one called from the contract that implements this handler. It's the entry point to protocol.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _sender the address triggering the contract action
     * @param _tokenId the token's specific ID
     * @return _success equals true if all checks pass
     */

    function checkAllRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,  address _sender, uint256 _tokenId) external override onlyOwner returns (bool) {
        bool isFromBypassAccount = appManager.isRuleBypassAccount(_from);
        bool isToBypassAccount = appManager.isRuleBypassAccount(_to);
        ActionTypes action = determineTransferAction(_from, _to, _sender);
        uint256 _amount = 1; /// currently not supporting batch NFT transactions. Only single NFT transfers.
        /// standard tagged and non-tagged rules do not apply when either to or from is an admin
        if (!isFromBypassAccount && !isToBypassAccount) {
            appManager.checkApplicationRules(address(msg.sender), _from, _to, _amount, nftValuationLimit, _tokenId, action, HandlerTypes.ERC721HANDLER);
            _checkTaggedAndTradingRules(_balanceFrom, _balanceTo, _from, _to, _amount, action);

            _checkNonTaggedRules(action, _from, _to, _amount, _tokenId);
            _checkSimpleRules(action, _tokenId);
            /// set the ownership start time for the token if the Minimum Hold time rule is active or action is mint
            if (minimumHoldTime[action].active || action == ActionTypes.MINT) ownershipStart[_tokenId] = block.timestamp;
        } else if (adminWithdrawal[action].active && isFromBypassAccount) {
            ruleProcessor.checkAdminWithdrawalRule(adminWithdrawal[action].ruleId, _balanceFrom, _amount);
            emit RulesBypassedViaRuleBypassAccount(address(msg.sender), appManagerAddress);
        }
        /// If all rule checks pass, return true
        return true;
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual rule checks.
     * @param action current action
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param tokenId the token's specific ID
     */
    function _checkNonTaggedRules(ActionTypes action, address _from, address _to, uint256 _amount, uint256 tokenId) internal {
        _from;
        for (uint256 oracleRuleIndex; oracleRuleIndex < oracle[action].length; ) {
            if (oracle[action][oracleRuleIndex].active) ruleProcessor.checkOraclePasses(oracle[action][oracleRuleIndex].ruleId, _to);
            unchecked {
                ++oracleRuleIndex;
            }
        }

        if (tradeCounter[action].active) {
            // get all the tags for this NFT
            bytes32[] memory tags = appManager.getAllTags(erc721Address);
            tradesInPeriod[tokenId] = ruleProcessor.checkNFTTransferCounter(tradeCounter[action].ruleId, tradesInPeriod[tokenId], tags, lastTxDate[tokenId]);
            lastTxDate[tokenId] = uint64(block.timestamp);
        }
        if (tokenTransferVolume[action].active) {
            transferVolume = ruleProcessor.checkTokenTransferVolumePasses(tokenTransferVolume[action].ruleId, transferVolume, IToken(msg.sender).totalSupply(), _amount, lastTransferTs);
            lastTransferTs = uint64(block.timestamp);
        }
        /// rule requires ruleID and either to or from address be zero address (mint/burn)
        if (totalSupplyVolatility[action].active && (action == ActionTypes.MINT || action == ActionTypes.BURN)) {
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
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTaggedIndividualRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) internal {
        bool mustCheckPurchaseRules = action == ActionTypes.PURCHASE && !appManager.isTradingRuleBypasser(_to);
        bool mustCheckSellRules = action == ActionTypes.SELL && !appManager.isTradingRuleBypasser(_from);
        if (minMaxBalance[action].active || minBalByDate[action].active || (mustCheckPurchaseRules && purchaseLimitRuleActive) || (mustCheckSellRules && sellLimitRuleActive)) {
            // We get all tags for sender and recipient
            bytes32[] memory toTags = appManager.getAllTags(_to);
            bytes32[] memory fromTags = appManager.getAllTags(_from);
            if (minMaxBalanceRuleActive) ruleProcessor.checkMinMaxAccountBalanceERC721(minMaxBalanceRuleId, _balanceFrom, _balanceTo, toTags, fromTags);
            if (minBalByDateRuleActive) ruleProcessor.checkMinBalByDatePasses(minBalByDateRuleId, _balanceFrom, _amount, fromTags);
        }
        if (minMaxBalance[action].active) ruleProcessor.checkMinMaxAccountBalancePasses(minMaxBalance[action].ruleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
        if (minBalByDate[action].active) ruleProcessor.checkMinBalByDatePasses(minBalByDate[action].ruleId, _balanceFrom, _amount, fromTags);
        if((mustCheckPurchaseRules && (purchaseLimitRuleActive || purchasePercentageRuleActive)) || (mustCheckSellRules && (sellLimitRuleActive || sellPercentageRuleActive)))
            _checkTradingRules(_from, _to, fromTags, toTags, _amount, action);
        
    }


    /**
     * @dev This function uses the protocol's ruleProcessor to perform the simple rule checks.(Ones that have simple parameters and so are not stored in the rule storage diamond)
     * @param _action action to be checked
     * @param _tokenId the specific token in question
     */
    function _checkSimpleRules(ActionTypes _action, uint256 _tokenId) internal view {
        if (minimumHoldTime[_action].active && ownershipStart[_tokenId] > 0) ruleProcessor.checkNFTHoldTime(minimumHoldTime[_action].minimumHoldTimeHours, ownershipStart[_tokenId]);
    }

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
     * @dev Set the tradeCounterRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setTradeCounterRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateNFTTransferCounter(_ruleId);
        for (uint i; i < _actions.length; ) {
            tradeCounter[_actions[i]].ruleId = _ruleId;
            tradeCounter[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(NFT_TRANSFER, _actions[i], _ruleId);
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
    function activateTradeCounterRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            tradeCounter[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(NFT_TRANSFER, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(NFT_TRANSFER, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Retrieve the trade counter rule id
     * @param _action the action type
     * @return tradeCounterRuleId
     */
    function getTradeCounterRuleId(ActionTypes _action) external view returns (uint32) {
        return tradeCounter[_action].ruleId;
    }

    /**
     * @dev Tells you if the tradeCounterRule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTradeCounterRuleActive(ActionTypes _action) external view returns (bool) {
        return tradeCounter[_action].active;
    }

    /**
     * @dev Set the parent ERC721 address
     * @param _address address of the ERC721
     */
    function setERC721Address(address _address) public appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_address == address(0)) revert ZeroAddress();
        erc721Address = _address;
        emit ERC721AddressSet(_address);
    }

    /**
     * @dev Retrieve the minimum balance by date rule id
     * @param _action the action type
     * @return minBalByDateRuleId rule id
     */
    function getMinBalByDateRule(ActionTypes _action) external view returns (uint32) {
        return minBalByDate[_action].ruleId;
    }

    /**
     * @dev Set the minBalByDateRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setMinBalByDateRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            ruleProcessor.validateMinBalByDate(_ruleId);
            minBalByDate[_actions[i]].ruleId = _ruleId;
            minBalByDate[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(MIN_ACCT_BAL_BY_DATE, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the min bal by date rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateMinBalByDateRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            minBalByDate[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(MIN_ACCT_BAL_BY_DATE, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(MIN_ACCT_BAL_BY_DATE, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the minBalByDateRuleActive is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isMinBalByDateActive(ActionTypes _action) external view returns (bool) {
        return minBalByDate[_action].active;
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

    /// -------------SIMPLE RULE SETTERS and GETTERS---------------
    /**
     * @dev Tells you if the minimum hold time rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateMinimumHoldTimeRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            minimumHoldTime[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(MINIMUM_HOLD_TIME, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(MINIMUM_HOLD_TIME, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Setter the minimum hold time rule hold hours
     * @param _actions the action types
     * @param _minimumHoldTimeHours minimum amount of time to hold the asset
     */
    function setMinimumHoldTimeHours(ActionTypes[] calldata _actions, uint32 _minimumHoldTimeHours) external ruleAdministratorOnly(appManagerAddress) {
        if (_minimumHoldTimeHours == 0) revert ZeroValueNotPermited();
        if (_minimumHoldTimeHours > MAX_HOLD_TIME_HOURS) revert PeriodExceeds5Years();
        for (uint i; i < _actions.length; ) {
            minimumHoldTime[_actions[i]].minimumHoldTimeHours = _minimumHoldTimeHours;
            minimumHoldTime[_actions[i]].active = true;
            emit ApplicationHandlerSimpleActionApplied(MINIMUM_HOLD_TIME, _actions[i], uint256(_minimumHoldTimeHours));
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Get the minimum hold time rule hold hours
     * @param _action the action type
     * @return minimumHoldTimeHours minimum amount of time to hold the asset
     */
    function getMinimumHoldTimeHours(ActionTypes _action) external view returns (uint32) {
        return minimumHoldTime[_action].minimumHoldTimeHours;
    }

    /**
     * @dev function to check if Minumum Hold Time is active
     * @param _action the action type
     * @return bool
     */
    function isMinimumHoldTimeActive(ActionTypes _action) external view returns (bool) {
        return minimumHoldTime[_action].active;
    }

    /**
     * @dev Set the NFT Valuation limit that will check collection price vs looping through each tokenId in collections
     * @param _newNFTValuationLimit set the number of NFTs in a wallet that will check for collection price vs individual token prices
     */
    function setNFTValuationLimit(uint16 _newNFTValuationLimit) public appAdministratorOrOwnerOnly(appManagerAddress) {
        nftValuationLimit = _newNFTValuationLimit;
        emit NFTValuationLimitUpdated(_newNFTValuationLimit);
    }

    /**
     * @dev Get the nftValuationLimit
     * @return nftValautionLimit number of NFTs in a wallet that will check for collection price vs individual token prices
     */
    function getNFTValuationLimit() external view returns (uint256) {
        return nftValuationLimit;
    }
}
