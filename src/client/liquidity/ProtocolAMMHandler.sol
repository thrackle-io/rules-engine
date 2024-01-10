// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/protocol/economic/IRuleProcessor.sol";
import "./IProtocolAMMHandler.sol";
import "src/client/token/ProtocolHandlerCommon.sol";

/**
 * @title ProtocolAMMHandler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs rule checks related to the the AMM that implements it.
 * @notice Any rules may be updated by modifying this contract and redeploying.
 */

contract ProtocolAMMHandler is Ownable, ProtocolHandlerCommon, IProtocolAMMHandler, RuleAdministratorOnly {
    /// Mapping lastUpdateTime for most recent previous tranaction through Protocol
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) purchasedWithinPeriod;
    mapping(address => uint256) salesWithinPeriod;
    mapping(address => uint64) lastSellTime;

    address public ruleProcessorAddress;
    uint64 public previousPurchaseTime;
    uint64 public previousSellTime;
    uint256 private totalPurchasedWithinPeriod; /// total number of tokens purchased in period
    uint256 private totalSoldWithinPeriod; /// total number of tokens purchased in period

    IERC20 public token;

    /// Rule ID's
    uint32 private purchaseLimitRuleId;
    uint32 private sellLimitRuleId;
    uint32 private minTransferRuleId;
    uint32 private minMaxBalanceRuleIdToken0;
    uint32 private minMaxBalanceRuleIdToken1;
    uint32 private oracleRuleId;
    uint32 private purchasePercentageRuleId;
    uint32 private sellPercentageRuleId;

    /// Fee ID's
    uint32 private ammFeeRuleId;

    /// Rule Activation Bools
    bool private purchaseLimitRuleActive;
    bool private sellLimitRuleActive;
    bool private minTransferRuleActive;
    bool private oracleRuleActive;
    bool private minMaxBalanceRuleActive;
    bool private purchasePercentageRuleActive;
    bool private sellPercentageRuleActive;

    /// Fee Activation Bools
    bool private ammFeeRuleActive;

    /**
     * @dev Constructor sets the App Manager andToken Rule Router Address
     * @param _appManagerAddress Application App Manager Address
     * @param _ruleProcessorProxyAddress Rule Processor Address
     * @param _assetAddress address of the controlling asset
     */
    constructor(address _appManagerAddress, address _ruleProcessorProxyAddress,address _assetAddress) {
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        transferOwnership(_assetAddress);
        ruleProcessorAddress = _ruleProcessorProxyAddress;
        emit HandlerDeployed(_appManagerAddress);
    }

    /**
     * @dev Function mirrors that of the checkRuleStorages. This is the rule check function to be called by the AMM.
     * @param token0BalanceFrom token balance of sender address
     * @param token1BalanceFrom token balance of sender address
     * @param _from sender address
     * @param _to recipient address
     * @param token_amount_0 number of tokens transferred
     * @param token_amount_1 number of tokens received
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return Success equals true if all checks pass
     */
    function checkAllRules(
        uint256 token0BalanceFrom,
        uint256 token1BalanceFrom,
        address _from,
        address _to,
        uint256 token_amount_0,
        uint256 token_amount_1,
        address _tokenAddress,
        ActionTypes _action
    ) external onlyOwner returns (bool) {
        bool isFromBypassAccount = appManager.isRuleBypassAccount(_from);
        bool isToBypassAccount = appManager.isRuleBypassAccount(_to);
        // // All transfers to treasury account are allowed
        if (!appManager.isTreasury(_to)) {
            /// standard tagged and  rules do not apply when either to or from is an admin
            if (!isFromBypassAccount && !isToBypassAccount) {
            appManager.checkApplicationRules(_action, _to, _from, 0, 0);
            _checkTaggedRules(token0BalanceFrom, token1BalanceFrom, _from, _to, token_amount_0, token_amount_1, _action);
            _checkNonTaggedRules(token0BalanceFrom, token1BalanceFrom, _from, _to, token_amount_0, token_amount_1, _tokenAddress, _action);
            } else {
                emit RulesBypassedViaRuleBypassAccount(address(msg.sender), appManagerAddress);
            }
        }
        return true;
    }

    /**
     * @dev Assess all the fees for the transaction
     * @param _balanceFrom Token balance of the sender address
     * @param _balanceTo Token balance of the recipient address
     * @param _from Sender address
     * @param _to Recipient address
     * @param _amount total number of tokens to be transferred
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return fees total assessed fee for transaction
     */
    function assessFees(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, ActionTypes _action) external view returns (uint256) {
        /// this is to silence warning from unused parameters. NOTE: These parameters are in here for parity and possible future use.
        _balanceFrom;
        _balanceTo;
        _from;
        _to;
        _amount;
        _action;
        uint256 fees;
        if (ammFeeRuleActive) fees += ruleProcessor.assessAMMFee(ammFeeRuleId, _amount);
        return fees;
    }

    /**
     * @dev Rule tracks all purchases by account for purchase Period, the timestamp of the most recent purchase and purchases are within the purchase period.
     * @param _token0BalanceFrom token balance of sender address
     * @param _token1BalanceFrom token balance of sender address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _token_amount_0 number of tokens transferred
     * @param _token_amount_1 number of tokens received
     */
    function _checkTaggedRules(
        uint256 _token0BalanceFrom,
        uint256 _token1BalanceFrom,
        address _from,
        address _to,
        uint256 _token_amount_0,
        uint256 _token_amount_1,
        ActionTypes _action
    ) internal {
        /// We get all tags for sender and recipient
        bytes32[] memory toTags = appManager.getAllTags(_to);
        bytes32[] memory fromTags = appManager.getAllTags(_from);
        address purchaseAccount = _to;
        address sellerAccount = _from;
        if (purchaseLimitRuleActive && _action == ActionTypes.PURCHASE) {
            purchasedWithinPeriod[purchaseAccount] = ruleProcessor.checkPurchaseLimit(
                purchaseLimitRuleId,
                purchasedWithinPeriod[purchaseAccount],
                _token_amount_0,
                toTags,
                lastPurchaseTime[purchaseAccount]
            );
            lastPurchaseTime[purchaseAccount] = uint64(block.timestamp);
        }

        if (sellLimitRuleActive && _action == ActionTypes.SELL) {
            salesWithinPeriod[sellerAccount] = ruleProcessor.checkSellLimit(sellLimitRuleId, salesWithinPeriod[sellerAccount], _token_amount_0, fromTags, lastSellTime[sellerAccount]);
            lastSellTime[sellerAccount] = uint64(block.timestamp);
        }
        /// Pass in fromTags twice because AMM address will not have tags applied (AMM Address is address_to).
        if (minMaxBalanceRuleActive) {
            ///Token 0
            ruleProcessor.checkMinMaxAccountBalancePassesAMM(minMaxBalanceRuleIdToken0, minMaxBalanceRuleIdToken1, _token0BalanceFrom, _token1BalanceFrom, _token_amount_0, _token_amount_1, fromTags);
            ruleProcessor.checkMinMaxAccountBalancePassesAMM(minMaxBalanceRuleIdToken1, minMaxBalanceRuleIdToken0, _token1BalanceFrom, _token0BalanceFrom, _token_amount_1, _token_amount_0, fromTags);
        }
    }

    /**
     * @dev Rule tracks all sales by account for sell Period, the timestamp of the most recent sale and sales are within the sell period.
     * @param _token0BalanceFrom token balance of sender address
     * @param _token1BalanceFrom token balance of sender address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _token_amount_0 number of tokens transferred
     * @param _token_amount_1 number of tokens received
     */
    function _checkNonTaggedRules(
        uint256 _token0BalanceFrom,
        uint256 _token1BalanceFrom,
        address _from,
        address _to,
        uint256 _token_amount_0,
        uint256 _token_amount_1,
        address _tokenAddress,
        ActionTypes _action
    ) internal {
        if (minTransferRuleActive) ruleProcessor.checkMinTransferPasses(minTransferRuleId, _token_amount_0);
        if (oracleRuleActive) ruleProcessor.checkOraclePasses(oracleRuleId, _from);
        /// Check rule is active and action taken is a purchase
        if (purchasePercentageRuleActive && _action == ActionTypes.PURCHASE) {
            uint256 tokenTotalSupply = getTotalSupply(_tokenAddress);
            totalPurchasedWithinPeriod = ruleProcessor.checkPurchasePercentagePasses(purchasePercentageRuleId, tokenTotalSupply, _token_amount_0, previousPurchaseTime, totalPurchasedWithinPeriod);
            previousPurchaseTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
        }
        /// Check rule is active and action taken is a sell
        if (sellPercentageRuleActive && _action == ActionTypes.SELL) {
            uint256 tokenTotalSupply = getTotalSupply(_tokenAddress);
            totalSoldWithinPeriod = ruleProcessor.checkSellPercentagePasses(sellPercentageRuleId, tokenTotalSupply, _token_amount_0, previousSellTime, totalSoldWithinPeriod);
            previousSellTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
        }
        ///silencing unused variable warnings
        _to;
        _token0BalanceFrom;
        _token1BalanceFrom;
        _token_amount_1;
    }

    /*********************************          Rule Setters and Getter            ********************************/

    /**
     *@dev this function gets the total supply of the address.
     *@param _token address of the token to call totalSupply() of.
     */
    function getTotalSupply(address _token) internal view returns (uint256) {
        return IERC20(_token).totalSupply();
    }

    /**
     * @dev Set the PurchaseLimitRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setPurchaseLimitRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        purchaseLimitRuleId = _ruleId;
        purchaseLimitRuleActive = true;
        emit ApplicationHandlerApplied(PURCHASE_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activatePurchaseLimitRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        purchaseLimitRuleActive = _on;
    }

    /**
     * @dev Retrieve the Purchase Limit rule id
     * @return purchaseLimitRuleId
     */
    function getPurchaseLimitRuleId() external view returns (uint32) {
        return purchaseLimitRuleId;
    }

    /**
     * @dev Tells you if the Purchase Limit Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isPurchaseLimitActive() external view returns (bool) {
        return purchaseLimitRuleActive;
    }

    /**
     * @dev Set the SellLimitRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setSellLimitRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        sellLimitRuleId = _ruleId;
        sellLimitRuleActive = true;
        emit ApplicationHandlerApplied(SELL_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateSellLimitRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        sellLimitRuleActive = _on;
    }

    /**
     * @dev Retrieve the Purchase Limit rule id
     * @return oracleRuleId
     */
    function getSellLimitRuleId() external view returns (uint32) {
        return sellLimitRuleId;
    }

    /**
     * @dev Tells you if the Purchase Limit Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isSellLimitActive() external view returns (bool) {
        return sellLimitRuleActive;
    }

    /**
     * @dev Get the block timestamp of the last purchase for account.
     * @return LastPurchaseTime for account
     */
    function getLastPurchaseTime(address account) external view ruleAdministratorOnly(appManagerAddress) returns (uint256) {
        return lastPurchaseTime[account];
    }

    /**
     * @dev Get the block timestamp of the last Sell for account.
     * @return LastSellTime for account
     */
    function getLastSellTime(address account) external view returns (uint256) {
        return lastSellTime[account];
    }

    /**
     * @dev Get the cumulative total of the purchases for account in purchase period.
     * @return purchasedWithinPeriod for account
     */
    function getPurchasedWithinPeriod(address account) external view returns (uint256) {
        return purchasedWithinPeriod[account];
    }

    /**
     * @dev Get the cumulative total of the Sales for account during sell period.
     * @return salesWithinPeriod for account
     */
    function getSalesWithinPeriod(address account) external view  returns (uint256) {
        return salesWithinPeriod[account];
    }

    /**
     * @dev Set the minTransferRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinTransferRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        minTransferRuleId = _ruleId;
        minTransferRuleActive = true;
        emit ApplicationHandlerApplied(MIN_TRANSFER, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransferRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minTransferRuleActive = _on;
    }

    /**
     * @dev Retrieve the minTransferRuleId
     * @return minTransferRuleId
     */
    function getMinTransferRuleId() external view returns (uint32) {
        return minTransferRuleId;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinTransferActive() external view returns (bool) {
        return minTransferRuleActive;
    }

    /**
     * @dev Set the minMaxBalanceRuleId for token 0. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleIdToken0(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleIdToken0 = _ruleId;
        minMaxBalanceRuleActive = true;
    }

    /**
     * @dev Set the minMaxBalanceRuleId for Token 1. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleIdToken1(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleIdToken1 = _ruleId;
        minMaxBalanceRuleActive = true;
        emit ApplicationHandlerApplied(MIN_MAX_BALANCE_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleActive = _on;
    }

    /**
     * Get the minMaxBalanceRuleIdToken0.
     * @return minMaxBalance rule id for token 0.
     */
    function getMinMaxBalanceRuleIdToken0() external view returns (uint32) {
        return minMaxBalanceRuleIdToken0;
    }

    /**
     * Get the minMaxBalanceRuleId for token 1.
     * @return minMaxBalance rule id for token 1.
     */
    function getMinMaxBalanceRuleIdToken1() external view returns (uint32) {
        return minMaxBalanceRuleIdToken1;
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
        oracleRuleId = _ruleId;
        oracleRuleActive = true;
        emit ApplicationHandlerApplied(ORACLE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateOracleRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        oracleRuleActive = _on;
    }

    /**
     * @dev Retrieve the oracle rule id
     * @return oracleRuleId
     */
    function getOracleRuleId() external view returns (uint32) {
        return oracleRuleId;
    }

    /**
     * @dev Tells you if the Oracle Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isOracleActive() external view returns (bool) {
        return oracleRuleActive;
    }

    /**
     * @dev Set the ammFeeRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAMMFeeRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ammFeeRuleId = _ruleId;
        ammFeeRuleActive = true;
        emit ApplicationHandlerApplied(AMM_FEE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param on_off boolean representing if a rule must be checked or not.
     */
    function activateAMMFeeRule(bool on_off) external ruleAdministratorOnly(appManagerAddress) {
        ammFeeRuleActive = on_off;
    }

    /**
     * @dev Retrieve the AMM Fee rule id
     * @return ammFeeRuleId
     */
    function getAMMFeeRuleId() external view returns (uint32) {
        return ammFeeRuleId;
    }

    /**
     * @dev Tells you if the AMM Fee Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAMMFeeRuleActive() external view returns (bool) {
        return ammFeeRuleActive;
    }

    /**
     * @dev Set the purchasePercentageRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setPurchasePercentageRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        purchasePercentageRuleId = _ruleId;
        purchasePercentageRuleActive = true;
        emit ApplicationHandlerApplied(PURCHASE_PERCENTAGE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activatePurchasePercentageRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        purchasePercentageRuleActive = _on;
    }

    /**
     * @dev Retrieve the Purchase Percentage Rule Id
     * @return purchasePercentageRuleId
     */
    function getPurchasePercentageRuleId() external view returns (uint32) {
        return purchasePercentageRuleId;
    }

    /**
     * @dev Tells you if the Purchase Percentage Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isPurchasePercentageRuleActive() external view returns (bool) {
        return purchasePercentageRuleActive;
    }

    /**
     * @dev Set the sellPercentageRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setSellPercentageRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        sellPercentageRuleId = _ruleId;
        sellPercentageRuleActive = true;
        emit ApplicationHandlerApplied(SELL_PERCENTAGE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateSellPercentageRuleIdRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        sellPercentageRuleActive = _on;
    }

    /**
     * @dev Retrieve the Purchase Percentage Rule Id
     * @return purchasePercentageRuleId
     */
    function getSellPercentageRuleId() external view returns (uint32) {
        return sellPercentageRuleId;
    }

    /**
     * @dev Tells you if the Purchase Percentage Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isSellPercentageRuleActive() external view returns (bool) {
        return sellPercentageRuleActive;
    }
}
