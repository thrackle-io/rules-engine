// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

/**
 * @title Base NFT Handler Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract performs all rule checks related to the the ERC721 that implements it.
 *      Any rule handlers may be updated by modifying this contract, redeploying, and pointing the ERC721 to the new version.
 * @notice This contract is the interaction point for the application ecosystem to the protocol
 */
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "./ProtocolHandlerCommon.sol";

contract ProtocolERC721Handler is Ownable, ProtocolHandlerCommon {
    /**
     * Functions added so far:
     * minAccountBalance
     * Min Max Balance
     * Oracle
     * Trade Counter
     * Balance By AccessLevel
     */
    address public erc721Address;
    /// RuleIds for implemented tagged rules of the ERC721
    uint32 private minMaxBalanceRuleId;
    uint32 private minBalByDateRuleId;
    uint32 private minAccountRuleId;
    uint32 private oracleRuleId;
    uint32 private tradeCounterRuleId;
    uint32 private transactionLimitByRiskRuleId;
    uint32 private adminWithdrawalRuleId;
    uint32 private tokenTransferVolumeRuleId;
    uint32 private totalSupplyVolatilityRuleId;
    /// on-off switches for rules
    bool private oracleRuleActive;
    bool private minMaxBalanceRuleActive;
    bool private tradeCounterRuleActive;
    bool private transactionLimitByRiskRuleActive;
    bool private minBalByDateRuleActive;
    bool private adminWithdrawalActive;
    bool private tokenTransferVolumeRuleActive;
    bool private totalSupplyVolatilityRuleActive;
    bool private minimumHoldTimeRuleActive;

    /// simple rule(with single parameter) variables
    uint32 private minimumHoldTimeHours;

    /// token level accumulators
    uint256 private transferVolume;
    uint64 private lastTransferTs;
    uint64 private lastSupplyUpdateTime;
    int256 private volumeTotalForPeriod;
    uint256 private totalSupplyForPeriod;
    /// NFT Collection Valuation Limit
    uint256 private nftValuationLimit;

    /// Trade Counter data
    // map the tokenId of this NFT to the number of trades in the period
    mapping(uint256 => uint256) tradesInPeriod;
    // map the tokenId of this NFT to the last transaction timestamp
    mapping(uint256 => uint64) lastTxDate;

    /// Minimum Hold time data
    mapping(uint256 => uint256) ownershipStart;

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _ruleProcessorProxyAddress of token rule router proxy
     * @param _appManagerAddress Address of App Manager
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, bool _upgradeMode) {
        if (_ruleProcessorProxyAddress == address(0) || _appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        /// Default value of 100 may be changed at any time with setNFTValuationLimit called by an app admin.
        setNFTValuationLimit(100);
        if (!_upgradeMode) {
            emit HandlerDeployed(address(this), _appManagerAddress);
        } else {
            emit HandlerDeployedForUpgrade(address(this), _appManagerAddress);
        }
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point to protocol.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param amount number of tokens transferred
     * @param _tokenId the token's specific ID
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return Success equals true if all checks pass
     */
    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, uint256 amount, uint256 _tokenId, ActionTypes _action) external returns (bool) {
        bool isFromAdmin = appManager.isAppAdministrator(_from);
        bool isToAdmin = appManager.isAppAdministrator(_to);
        /// standard tagged and non-tagged rules do not apply when either to or from is an admin
        if (!isFromAdmin && !isToAdmin) {
            uint128 balanceValuation;
            uint128 transferValuation;
            if (appManager.requireValuations()) {
                balanceValuation = uint128(getAccTotalValuation(_to));
                transferValuation = uint128(nftPricer.getNFTPrice(msg.sender, _tokenId));
            }
            appManager.checkApplicationRules(_action, _from, _to, balanceValuation, transferValuation);
            _checkTaggedRules(balanceFrom, balanceTo, _from, _to, amount, _tokenId);
            _checkNonTaggedRules(balanceFrom, balanceTo, _from, _to, amount, _tokenId);
            _checkSimpleRules(_tokenId);
        } else {
            if (adminWithdrawalActive && isFromAdmin) ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, balanceFrom, amount);
        }
        /// set the ownership start time for the token if the Minimum Hold time rule is active
        if (minimumHoldTimeRuleActive) ownershipStart[_tokenId] = block.timestamp;
        // If everything checks out, return true
        return true;
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param tokenId the token's specific ID
     */
    function _checkNonTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, uint256 tokenId) internal {
        if (oracleRuleActive) ruleProcessor.checkOraclePasses(oracleRuleId, _to);
        _balanceFrom;
        _balanceTo;
        _from;
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
     */
    function _checkTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, uint256 tokenId) internal view {
        _checkTaggedIndividualRules(_from, _to, _balanceFrom, _balanceTo, _amount);

        if (transactionLimitByRiskRuleActive) {
            /// If more rules need these values, then this can be moved above.
            uint256 currentAssetValuation = getAccTotalValuation(_to);
            uint256 thisNFTValuation = nftPricer.getNFTPrice(msg.sender, tokenId);
            _checkRiskRules(_from, _to, currentAssetValuation, _amount, thisNFTValuation);
        }
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged non-risk rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _amount number of tokens transferred
     */
    function _checkTaggedIndividualRules(address _from, address _to, uint256 _balanceFrom, uint256 _balanceTo, uint256 _amount) internal view {
        if (minMaxBalanceRuleActive || minBalByDateRuleActive) {
            // We get all tags for sender and recipient
            bytes32[] memory toTags = appManager.getAllTags(_to);
            bytes32[] memory fromTags = appManager.getAllTags(_from);
            if (minMaxBalanceRuleActive) ruleProcessor.checkMinMaxAccountBalancePasses(minMaxBalanceRuleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
            if (minBalByDateRuleActive) ruleProcessor.checkMinBalByDatePasses(minBalByDateRuleId, _balanceFrom, _amount, fromTags);
        }
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the risk rule checks.(Ones that require risk score values)
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _currentAssetValuation current total valuation of all assets
     * @param _amount number of tokens transferred
     * @param _thisNFTValuation valuation of NFT in question
     */
    function _checkRiskRules(address _from, address _to, uint256 _currentAssetValuation, uint256 _amount, uint256 _thisNFTValuation) internal view {
        _currentAssetValuation;
        _amount;
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);

        if (transactionLimitByRiskRuleActive) {
            ruleProcessor.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreFrom, _thisNFTValuation);
            ruleProcessor.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreTo, _thisNFTValuation);
        }
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
    function setMinMaxBalanceRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        minMaxBalanceRuleId = _ruleId;
        minMaxBalanceRuleActive = true;
        emit ApplicationHandlerApplied(MIN_MAX_BALANCE_LIMIT, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        minMaxBalanceRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_MAX_BALANCE_LIMIT, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MIN_MAX_BALANCE_LIMIT, address(this));
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
    function setOracleRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        oracleRuleId = _ruleId;
        oracleRuleActive = true;
        emit ApplicationHandlerApplied(ORACLE, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateOracleRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        oracleRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ORACLE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(ORACLE, address(this));
        }
    }

    /**
     * @dev Retrieve the oracle rule id
     * @return oracleRuleId
     */
    function getOracleRuleId() external view returns (uint32) {
        return oracleRuleId;
    }

    /**
     * @dev Tells you if the oracle rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isOracleActive() external view returns (bool) {
        return oracleRuleActive;
    }

    /**
     * @dev Set the tradeCounterRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTradeCounterRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        tradeCounterRuleId = _ruleId;
        tradeCounterRuleActive = true;
        emit ApplicationHandlerApplied(NFT_TRANSFER, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTradeCounterRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        tradeCounterRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(NFT_TRANSFER, address(this));
        } else {
            emit ApplicationHandlerDeactivated(NFT_TRANSFER, address(this));
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
    function setERC721Address(address _address) external appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_address == address(0)) revert ZeroAddress();
        erc721Address = _address;
    }

    /**
     * @dev Retrieve the oracle rule id
     * @return transactionLimitByRiskRuleActive rule id
     */
    function getTransactionLimitByRiskRule() external view returns (uint32) {
        return transactionLimitByRiskRuleId;
    }

    /**
     * @dev Set the TransactionLimitByRiskRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTransactionLimitByRiskRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        transactionLimitByRiskRuleId = _ruleId;
        transactionLimitByRiskRuleActive = true;
        emit ApplicationHandlerApplied(TX_SIZE_BY_RISK, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTransactionLimitByRiskRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        transactionLimitByRiskRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(TX_SIZE_BY_RISK, address(this));
        } else {
            emit ApplicationHandlerDeactivated(TX_SIZE_BY_RISK, address(this));
        }
    }

    /**
     * @dev Tells you if the transactionLimitByRiskRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTransactionLimitByRiskActive() external view returns (bool) {
        return transactionLimitByRiskRuleActive;
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
    function setMinBalByDateRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        minBalByDateRuleId = _ruleId;
        minBalByDateRuleActive = true;
        emit ApplicationHandlerApplied(MIN_ACCT_BAL_BY_DATE, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the min bal by date rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateMinBalByDateRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        minBalByDateRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_ACCT_BAL_BY_DATE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MIN_ACCT_BAL_BY_DATE, address(this));
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
    function setAdminWithdrawalRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (adminWithdrawalActive) {
            ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, 1, 1);
        }
        /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
        adminWithdrawalRuleId = _ruleId;
        adminWithdrawalActive = true;
        emit ApplicationHandlerApplied(ADMIN_WITHDRAWAL, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAdminWithdrawalRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, 1, 1);
        }
        adminWithdrawalActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ADMIN_WITHDRAWAL, address(this));
        } else {
            emit ApplicationHandlerDeactivated(ADMIN_WITHDRAWAL, address(this));
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
    function setTokenTransferVolumeRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        tokenTransferVolumeRuleId = _ruleId;
        tokenTransferVolumeRuleActive = true;
        emit ApplicationHandlerApplied(TRANSFER_VOLUME, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the token transfer volume rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTokenTransferVolumeRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        tokenTransferVolumeRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(TRANSFER_VOLUME, address(this));
        } else {
            emit ApplicationHandlerDeactivated(TRANSFER_VOLUME, address(this));
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
    function setTotalSupplyVolatilityRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        totalSupplyVolatilityRuleId = _ruleId;
        totalSupplyVolatilityRuleActive = true;
        emit ApplicationHandlerApplied(SUPPLY_VOLATILITY, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the token total Supply Volatility rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTotalSupplyVolatilityRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        totalSupplyVolatilityRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(SUPPLY_VOLATILITY, address(this));
        } else {
            emit ApplicationHandlerDeactivated(SUPPLY_VOLATILITY, address(this));
        }
    }

    /**
     * @dev Tells you if the Total Supply Volatility is active or not.
     * @return boolean representing if the rule is active
     */
    function isTotalSupplyVolatilityActive() external view returns (bool) {
        return totalSupplyVolatilityRuleActive;
    }

    /// -------------SIMPLE RULE SETTERS and GETTERS---------------
    /**
     * @dev Tells you if the minimum hold time rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateMinimumHoldTimeRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        minimumHoldTimeRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MINIMUM_HOLD_TIME, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MINIMUM_HOLD_TIME, address(this));
        }
    }

    /**
     * @dev Setter the minimum hold time rule hold hours
     * @param _minimumHoldTimeHours minimum amount of time to hold the asset
     */
    function setMinimumHoldTimeHours(uint32 _minimumHoldTimeHours) external appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_minimumHoldTimeHours == 0) revert ZeroValueNotPermited();
        if (_minimumHoldTimeHours > 43830) revert PeriodExceeds5Years();
        minimumHoldTimeHours = _minimumHoldTimeHours;
        minimumHoldTimeRuleActive = true;
        emit ApplicationHandlerSimpleApplied(MINIMUM_HOLD_TIME, address(this), uint256(minimumHoldTimeHours));
    }

    /**
     * @dev Get the minimum hold time rule hold hours
     * @return minimumHoldTimeHours minimum amount of time to hold the asset
     */
    function getMinimumHoldTimeHours() external view returns (uint256) {
        return minimumHoldTimeHours;
    }

    /**
     * @dev Set the NFT Valuation limit that will check collection price vs looping through each tokenId in collections
     * @param _newNFTValuationLimit set the number of NFTs in a wallet that will check for collection price vs individual token prices
     */
    function setNFTValuationLimit(uint256 _newNFTValuationLimit) public appAdministratorOrOwnerOnly(appManagerAddress) {
        nftValuationLimit = _newNFTValuationLimit;
        emit NFTValuationLimitUpdated(_newNFTValuationLimit, address(this));
    }

    /**
     * @dev Get the nftValuationLimit
     * @return nftValautionLimit number of NFTs in a wallet that will check for collection price vs individual token prices
     */
    function getNFTValuationLimit() external view returns (uint256) {
        return nftValuationLimit;
    }
}
