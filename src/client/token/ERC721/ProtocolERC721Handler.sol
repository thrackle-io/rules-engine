// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "src/client/token/ProtocolHandlerCommon.sol";

/**
 * @title Base NFT Handler Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract performs all rule checks related to the the ERC721 that implements it.
 *      Any rule handlers may be updated by modifying this contract, redeploying, and pointing the ERC721 to the new version.
 * @notice This contract is the interaction point for the application ecosystem to the protocol
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../ProtocolHandlerCommon.sol";
import "../ProtocolHandlerTradingRulesCommon.sol";

contract ProtocolERC721Handler is Ownable, ProtocolHandlerCommon, ProtocolHandlerTradingRulesCommon, IProtocolTokenHandler, IAdminWithdrawalRuleCapable, ERC165 {
    
    address public erc721Address;

    struct OracleRule {
        uint32 oracleRuleId;
        bool oracleRuleActive;
    }

    /// RuleIds for implemented tagged rules of the ERC721
    uint32 private minMaxBalanceRuleId;
    uint32 private minBalByDateRuleId;
    uint32 private minAccountRuleId;
    OracleRule[] private oracleRules;
    uint32 private tradeCounterRuleId;
    uint32 private adminWithdrawalRuleId;
    uint32 private tokenTransferVolumeRuleId;
    uint32 private totalSupplyVolatilityRuleId;
    /// on-off switches for rules
    bool private minMaxBalanceRuleActive;
    bool private tradeCounterRuleActive;
    bool private minBalByDateRuleActive;
    bool private adminWithdrawalActive;
    bool private tokenTransferVolumeRuleActive;
    bool private totalSupplyVolatilityRuleActive;
    bool private minimumHoldTimeRuleActive;

    /// simple rule(with single parameter) variables
    uint32 private minimumHoldTimeHours;

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
    uint16 constant MAX_ORACLE_RULES = 10;

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

            _checkNonTaggedRules(_from, _to, _amount, _tokenId);
            _checkSimpleRules(_tokenId);
            /// set the ownership start time for the token if the Minimum Hold time rule is active
            if (minimumHoldTimeRuleActive) ownershipStart[_tokenId] = block.timestamp;
        } else if (adminWithdrawalActive && isFromBypassAccount) {
            ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, _balanceFrom, _amount);
            emit RulesBypassedViaRuleBypassAccount(address(msg.sender), appManagerAddress);
        }
        /// If all rule checks pass, return true
        return true;
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param tokenId the token's specific ID
     */
    function _checkNonTaggedRules(address _from, address _to, uint256 _amount, uint256 tokenId) internal {
        for (uint256 oracleRuleIndex; oracleRuleIndex < oracleRules.length; ) {
            if (oracleRules[oracleRuleIndex].oracleRuleActive) ruleProcessor.checkOraclePasses(oracleRules[oracleRuleIndex].oracleRuleId, _to);
            unchecked {
                ++oracleRuleIndex;
            }
        }

        if (tradeCounterRuleActive) {
            // get all the tags for this NFT
            bytes32[] memory tags = appManager.getAllTags(erc721Address);
            tradesInPeriod[tokenId] = ruleProcessor.checkNFTTransferCounter(tradeCounterRuleId, tradesInPeriod[tokenId], tags, lastTxDate[tokenId]);
            lastTxDate[tokenId] = uint64(block.timestamp);
        }
        if (tokenTransferVolumeRuleActive) {
            transferVolume = ruleProcessor.checkTokenTransferVolumePasses(tokenTransferVolumeRuleId, transferVolume, IToken(msg.sender).totalSupply(), _amount, lastTransferTs);
            lastTransferTs = uint64(block.timestamp);
        }
        /// rule requires ruleID and either to or from address be zero address (mint/burn)
        if (totalSupplyVolatilityRuleActive && (_from == address(0x00) || _to == address(0x00))) {
            (volumeTotalForPeriod, totalSupplyForPeriod) = ruleProcessor.checkTotalSupplyVolatilityPasses(
                totalSupplyVolatilityRuleId,
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
        bytes32[] memory toTags;
        bytes32[] memory fromTags;
        bool mustCheckPurchaseRules = action == ActionTypes.PURCHASE && !appManager.isTradingRuleBypasser(_to);
        bool mustCheckSellRules = action == ActionTypes.SELL && !appManager.isTradingRuleBypasser(_from);
        if (minMaxBalanceRuleActive || minBalByDateRuleActive || (mustCheckPurchaseRules && purchaseLimitRuleActive) || (mustCheckSellRules && sellLimitRuleActive)) {
            // We get all tags for sender and recipient
            toTags = appManager.getAllTags(_to);
            fromTags = appManager.getAllTags(_from);
        }
        if (minMaxBalanceRuleActive) ruleProcessor.checkMinMaxAccountBalancePasses(minMaxBalanceRuleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
        if (minBalByDateRuleActive) ruleProcessor.checkMinBalByDatePasses(minBalByDateRuleId, _balanceFrom, _amount, fromTags);
        if((mustCheckPurchaseRules && (purchaseLimitRuleActive || purchasePercentageRuleActive)) || (mustCheckSellRules && (sellLimitRuleActive || sellPercentageRuleActive)))
            _checkTradingRules(_from, _to, fromTags, toTags, _amount, action);
        
    }


    /**
     * @dev This function uses the protocol's ruleProcessor to perform the simple rule checks.(Ones that have simple parameters and so are not stored in the rule storage diamond)
     * @param _tokenId the specific token in question
     */
    function _checkSimpleRules(uint256 _tokenId) internal view {
        if (minimumHoldTimeRuleActive && ownershipStart[_tokenId] > 0) ruleProcessor.checkNFTHoldTime(minimumHoldTimeHours, ownershipStart[_tokenId]);
    }

    /**
     * @dev Set the minMaxBalanceRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinMaxAccountBalance(_ruleId);
        minMaxBalanceRuleId = _ruleId;
        minMaxBalanceRuleActive = true;
        emit ApplicationHandlerApplied(MIN_MAX_BALANCE_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_MAX_BALANCE_LIMIT);
        } else {
            emit ApplicationHandlerDeactivated(MIN_MAX_BALANCE_LIMIT);
        }
    }

    /**
     * Get the minMaxBalanceRuleId.
     * @return minMaxBalance rule id.
     */
    function getMinMaxBalanceRuleId() external view returns (uint32) {
        return minMaxBalanceRuleId;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinMaxBalanceActive() external view returns (bool) {
        return minMaxBalanceRuleActive;
    }

    /**
     * @dev Set the oracleRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setOracleRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        if (oracleRules.length >= MAX_ORACLE_RULES) {
            revert OracleRulesPerAssetLimitReached();
        }
        ruleProcessor.validateOracle(_ruleId);

        OracleRule memory newEntity;
        newEntity.oracleRuleId = _ruleId;
        newEntity.oracleRuleActive = true;
        oracleRules.push(newEntity);
        emit ApplicationHandlerApplied(ORACLE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     * @param ruleId the id of the rule to activate/deactivate
     */

    function activateOracleRule(bool _on, uint32 ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint256 oracleRuleIndex; oracleRuleIndex < oracleRules.length; ) {
            if (oracleRules[oracleRuleIndex].oracleRuleId == ruleId) {
                oracleRules[oracleRuleIndex].oracleRuleActive = _on;

                if (_on) {
                    emit ApplicationHandlerActivated(ORACLE, address(this));
                } else {
                    emit ApplicationHandlerDeactivated(ORACLE, address(this));
                }
            }
            unchecked {
                ++oracleRuleIndex;
            }
        }
    }

    /**
     * @dev Retrieve the oracle rule id
     * @return oracleRuleId
     */
    function getOracleRuleIds() external view returns (uint32[] memory ) {
        uint32[] memory ruleIds = new uint32[](oracleRules.length);
        for (uint256 oracleRuleIndex; oracleRuleIndex < oracleRules.length; ) {
            ruleIds[oracleRuleIndex] = oracleRules[oracleRuleIndex].oracleRuleId;
            unchecked {
                ++oracleRuleIndex;
            }
        }
        return ruleIds;
    }

    /**
     * @dev Tells you if the Oracle Rule is active or not.
     * @param ruleId the id of the rule to check
     * @return boolean representing if the rule is active
     */
    function isOracleActive(uint32 ruleId) external view returns (bool) {
        for (uint256 oracleRuleIndex; oracleRuleIndex < oracleRules.length; ) {
            if (oracleRules[oracleRuleIndex].oracleRuleId == ruleId) {
                return oracleRules[oracleRuleIndex].oracleRuleActive;
            }
            unchecked {
                ++oracleRuleIndex;
            }
        }
        return false;
    }

    /**
     * @dev Removes an oracle rule from the list.
     * @param ruleId the id of the rule to remove
     */
    function removeOracleRule(uint32 ruleId) external ruleAdministratorOnly(appManagerAddress) {
        OracleRule memory lastId = oracleRules[oracleRules.length -1];
        if(ruleId != lastId.oracleRuleId){
            uint index = 0;
            for (uint256 oracleRuleIndex; oracleRuleIndex < oracleRules.length; ) {
                if (oracleRules[oracleRuleIndex].oracleRuleId == ruleId) {
                    index = oracleRuleIndex; 
                    break;
                }
                unchecked {
                    ++oracleRuleIndex;
                }
            }
            oracleRules[index] = lastId;
        }

        oracleRules.pop();
    }


    /**
     * @dev Set the tradeCounterRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTradeCounterRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateNFTTransferCounter(_ruleId);
        tradeCounterRuleId = _ruleId;
        tradeCounterRuleActive = true;
        emit ApplicationHandlerApplied(NFT_TRANSFER, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTradeCounterRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        tradeCounterRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(NFT_TRANSFER);
        } else {
            emit ApplicationHandlerDeactivated(NFT_TRANSFER);
        }
    }

    /**
     * @dev Retrieve the trade counter rule id
     * @return tradeCounterRuleId
     */
    function getTradeCounterRuleId() external view returns (uint32) {
        return tradeCounterRuleId;
    }

    /**
     * @dev Tells you if the tradeCounterRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTradeCounterRuleActive() external view returns (bool) {
        return tradeCounterRuleActive;
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
     * @return minBalByDateRuleId rule id
     */
    function getMinBalByDateRule() external view returns (uint32) {
        return minBalByDateRuleId;
    }

    /**
     * @dev Set the minBalByDateRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinBalByDateRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinBalByDate(_ruleId);
        minBalByDateRuleId = _ruleId;
        minBalByDateRuleActive = true;
        emit ApplicationHandlerApplied(MIN_ACCT_BAL_BY_DATE, _ruleId);
    }

    /**
     * @dev Tells you if the min bal by date rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateMinBalByDateRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minBalByDateRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_ACCT_BAL_BY_DATE);
        } else {
            emit ApplicationHandlerDeactivated(MIN_ACCT_BAL_BY_DATE);
        }
    }

    /**
     * @dev Tells you if the minBalByDateRuleActive is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinBalByDateActive() external view returns (bool) {
        return minBalByDateRuleActive;
    }

    /**
     * @dev Set the AdminWithdrawalRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAdminWithdrawalRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAdminWithdrawal(_ruleId);
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (adminWithdrawalActive) {
            if (isAdminWithdrawalActiveAndApplicable()) revert AdminWithdrawalRuleisActive();
        }
        /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
        adminWithdrawalRuleId = _ruleId;
        adminWithdrawalActive = true;
        emit ApplicationHandlerApplied(ADMIN_WITHDRAWAL, _ruleId);
    }

    /**
     * @dev This function is used by the app manager to determine if the AdminWithdrawal rule is active
     * @return Success equals true if all checks pass
     */
    function isAdminWithdrawalActiveAndApplicable() public view override returns (bool) {
        bool active;
        if (adminWithdrawalActive) {
            try ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, 1, 1) {} catch {
                active = true;
            }
        }
        return active;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAdminWithdrawalRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            if (isAdminWithdrawalActiveAndApplicable()) revert AdminWithdrawalRuleisActive();
        }
        adminWithdrawalActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ADMIN_WITHDRAWAL);
        } else {
            emit ApplicationHandlerDeactivated(ADMIN_WITHDRAWAL);
        }
    }

    /**
     * @dev Tells you if the admin withdrawal rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAdminWithdrawalActive() external view returns (bool) {
        return adminWithdrawalActive;
    }

    /**
     * @dev Retrieve the admin withdrawal rule id
     * @return adminWithdrawalRuleId rule id
     */
    function getAdminWithdrawalRuleId() external view returns (uint32) {
        return adminWithdrawalRuleId;
    }

    /**
     * @dev Retrieve the token transfer volume rule id
     * @return tokenTransferVolumeRuleId rule id
     */
    function getTokenTransferVolumeRule() external view returns (uint32) {
        return tokenTransferVolumeRuleId;
    }

    /**
     * @dev Set the tokenTransferVolumeRuleId. Restricted to game admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTokenTransferVolumeRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateTokenTransferVolume(_ruleId);
        tokenTransferVolumeRuleId = _ruleId;
        tokenTransferVolumeRuleActive = true;
        emit ApplicationHandlerApplied(TRANSFER_VOLUME, _ruleId);
    }

    /**
     * @dev Tells you if the token transfer volume rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTokenTransferVolumeRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        tokenTransferVolumeRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(TRANSFER_VOLUME);
        } else {
            emit ApplicationHandlerDeactivated(TRANSFER_VOLUME);
        }
    }

    /**
     * @dev Retrieve the total supply volatility rule id
     * @return totalSupplyVolatilityRuleId rule id
     */
    function getTotalSupplyVolatilityRule() external view returns (uint32) {
        return totalSupplyVolatilityRuleId;
    }

    /**
     * @dev Set the tokenTransferVolumeRuleId. Restricted to game admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTotalSupplyVolatilityRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateSupplyVolatility(_ruleId);
        totalSupplyVolatilityRuleId = _ruleId;
        totalSupplyVolatilityRuleActive = true;
        emit ApplicationHandlerApplied(SUPPLY_VOLATILITY, _ruleId);
    }

    /**
     * @dev Tells you if the token total Supply Volatility rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTotalSupplyVolatilityRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        totalSupplyVolatilityRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(SUPPLY_VOLATILITY);
        } else {
            emit ApplicationHandlerDeactivated(SUPPLY_VOLATILITY);
        }
    }

    /**
     * @dev Tells you if the Total Supply Volatility is active or not.
     * @return boolean representing if the rule is active
     */
    function isTotalSupplyVolatilityActive() external view returns (bool) {
        return totalSupplyVolatilityRuleActive;
    }

    /**
     *@dev this function gets the total supply of the address.
     *@param _token address of the token to call totalSupply() of.
     */
    function getTotalSupply(address _token) internal view returns (uint256) {
        return IERC20(_token).totalSupply();
    }

    /// -------------SIMPLE RULE SETTERS and GETTERS---------------
    /**
     * @dev Tells you if the minimum hold time rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateMinimumHoldTimeRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minimumHoldTimeRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MINIMUM_HOLD_TIME);
        } else {
            emit ApplicationHandlerDeactivated(MINIMUM_HOLD_TIME);
        }
    }

    /**
     * @dev Setter the minimum hold time rule hold hours
     * @param _minimumHoldTimeHours minimum amount of time to hold the asset
     */
    function setMinimumHoldTimeHours(uint32 _minimumHoldTimeHours) external ruleAdministratorOnly(appManagerAddress) {
        if (_minimumHoldTimeHours == 0) revert ZeroValueNotPermited();
        if (_minimumHoldTimeHours > MAX_HOLD_TIME_HOURS) revert PeriodExceeds5Years();
        minimumHoldTimeHours = _minimumHoldTimeHours;
        minimumHoldTimeRuleActive = true;
        emit ApplicationHandlerSimpleApplied(MINIMUM_HOLD_TIME, uint256(minimumHoldTimeHours));
    }

    /**
     * @dev Get the minimum hold time rule hold hours
     * @return minimumHoldTimeHours minimum amount of time to hold the asset
     */
    function getMinimumHoldTimeHours() external view returns (uint32) {
        return minimumHoldTimeHours;
    }

    /**
     * @dev function to check if Minumum Hold Time is active
     * @return bool
     */
    function isMinimumHoldTimeActive() external view returns (bool) {
        return minimumHoldTimeRuleActive;
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
