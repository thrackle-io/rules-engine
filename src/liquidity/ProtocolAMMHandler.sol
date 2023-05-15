// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "../economic/ITokenRuleRouter.sol";
import "../application/IAppManager.sol";
import "./IProtocolAMMHandler.sol";
import "../economic/AppAdministratorOnly.sol";
import {ITokenHandlerEvents} from "../interfaces/IEvents.sol";

import "../economic/ruleStorage/RuleCodeData.sol";

/**
 * @title ProtocolAMMHandler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs rule checks related to the the AMM that implements it.
 * @notice Any rules may be updated by modifying this contract and redeploying.
 */

contract ProtocolAMMHandler is Ownable, AppAdministratorOnly, ITokenHandlerEvents, IProtocolAMMHandler {
    /// Mapping lastUpdateTime for most recent previous tranaction through Protocol
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) purchasedWithinPeriod;
    mapping(address => uint256) salesWithinPeriod;
    mapping(address => uint256) lastSellTime;

    address public appManagerAddress;
    address public ruleRouterAddress;

    ITokenRuleRouter immutable ruleRouter;
    IAppManager appManager;

    /// Rule ID's
    uint32 private purchaseLimitRuleId;
    uint32 private sellLimitRuleId;
    uint32 private minTransferRuleId;
    uint32 private minMaxBalanceRuleIdToken0;
    uint32 private minMaxBalanceRuleIdToken1;
    uint32 private oracleRuleId;

    /// Fee ID's
    uint32 private ammFeeRuleId;

    /// Rule Activation Bools
    bool private purchaseLimitRuleActive;
    bool private sellLimitRuleActive;
    bool private minTransferRuleActive;
    bool private oracleRuleActive;
    bool private minMaxBalanceRuleActive;

    /// Fee Activation Bools
    bool private ammFeeRuleActive;

    /**
     * @dev Constructor sets the App Manager andToken Rule Router Address
     * @param _appManagerAddress Application App Manager Address
     * @param _tokenRuleRouterProxyAddress Token Rule RouterProxy Address
     */
    constructor(address _appManagerAddress, address _tokenRuleRouterProxyAddress) {
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleRouter = ITokenRuleRouter(_tokenRuleRouterProxyAddress);
        ruleRouterAddress = _tokenRuleRouterProxyAddress;
        emit HandlerDeployed(address(this), _appManagerAddress);
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
        ApplicationRuleProcessorDiamondLib.ActionTypes _action
    ) external returns (bool) {
        bool isFromAdmin = appManager.isAppAdministrator(_from);
        bool isToAdmin = appManager.isAppAdministrator(_to);
        // // All transfers to treasury account are allowed
        if (!appManager.isTreasury(_to)) {
            /// standard tagged and  rules do not apply when either to or from is an admin
            if (!isFromAdmin && !isToAdmin) appManager.checkApplicationRules(_action, _to, _from, 0, 0);
            _checkTaggedRules(token0BalanceFrom, token1BalanceFrom, _from, _to, token_amount_0, token_amount_1);
            _checkNonTaggedRules(token0BalanceFrom, token1BalanceFrom, _from, _to, token_amount_0, token_amount_1);
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
    function assessFees(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, ApplicationRuleProcessorDiamondLib.ActionTypes _action) external view returns (uint256) {
        /// this is to silence warning from unused parameters. NOTE: These parameters are in here for parity and possible future use.
        _balanceFrom;
        _balanceTo;
        _from;
        _to;
        _amount;
        _action;
        uint256 fees;
        if (ammFeeRuleActive) fees += ruleRouter.assessAMMFee(ammFeeRuleId, _amount);
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
    function _checkTaggedRules(uint256 _token0BalanceFrom, uint256 _token1BalanceFrom, address _from, address _to, uint256 _token_amount_0, uint256 _token_amount_1) internal {
        /// We get all tags for sender and recipient
        bytes32[] memory toTags = appManager.getAllTags(_to);
        bytes32[] memory fromTags = appManager.getAllTags(_from);
        address purchaseAccount = _to;
        address sellerAccount = _from;
        if (purchaseLimitRuleActive) {
            purchasedWithinPeriod[purchaseAccount] = ruleRouter.checkPurchaseLimit(
                purchaseLimitRuleId,
                purchasedWithinPeriod[purchaseAccount],
                _token_amount_0,
                toTags,
                lastPurchaseTime[purchaseAccount]
            );
            lastPurchaseTime[purchaseAccount] = uint64(block.timestamp);
        }

        if (sellLimitRuleActive) {
            salesWithinPeriod[sellerAccount] = ruleRouter.checkSellLimit(sellLimitRuleId, salesWithinPeriod[sellerAccount], _token_amount_0, fromTags, lastSellTime[sellerAccount]);
            lastSellTime[sellerAccount] = block.timestamp;
        }
        /// Pass in fromTags twice because AMM address will not have tags applied (AMM Address is address_to).
        if (minMaxBalanceRuleActive) {
            ///Token 0
            ruleRouter.checkMinMaxAccountBalancePassesAMM(minMaxBalanceRuleIdToken0, minMaxBalanceRuleIdToken1, _token0BalanceFrom, _token1BalanceFrom, _token_amount_0, _token_amount_1, fromTags);
            ruleRouter.checkMinMaxAccountBalancePassesAMM(minMaxBalanceRuleIdToken1, minMaxBalanceRuleIdToken0, _token1BalanceFrom, _token0BalanceFrom, _token_amount_1, _token_amount_0, fromTags);
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
    function _checkNonTaggedRules(uint256 _token0BalanceFrom, uint256 _token1BalanceFrom, address _from, address _to, uint256 _token_amount_0, uint256 _token_amount_1) internal view {
        if (minTransferRuleActive) ruleRouter.checkMinTransferPasses(minTransferRuleId, _token_amount_0);
        if (oracleRuleActive) ruleRouter.checkOraclePasses(oracleRuleId, _from);
        ///silencing unused variable warnings
        _to;
        _token0BalanceFrom;
        _token1BalanceFrom;
        _token_amount_1;
    }

    /*********************************          Rule Setters and Getter            ********************************/

    /**
     * @dev Set the PurchaseLimitRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setPurchaseLimitRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        purchaseLimitRuleId = _ruleId;
        purchaseLimitRuleActive = true;
        emit ApplicationHandlerApplied(PURCHASE_LIMIT, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activatePurchaseLimitRule(bool _on) external appAdministratorOnly(appManagerAddress) {
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
    function setSellLimitRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        sellLimitRuleId = _ruleId;
        sellLimitRuleActive = true;
        emit ApplicationHandlerApplied(SELL_LIMIT, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateSellLimitRule(bool _on) external appAdministratorOnly(appManagerAddress) {
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
    function getLastPurchaseTime(address account) external view appAdministratorOnly(appManagerAddress) returns (uint256) {
        return lastPurchaseTime[account];
    }

    /**
     * @dev Get the block timestamp of the last Sell for account.
     * @return LastSellTime for account
     */
    function getLastSellTime(address account) external view appAdministratorOnly(appManagerAddress) returns (uint256) {
        return lastSellTime[account];
    }

    /**
     * @dev Get the cumulative total of the purchases for account in purchase period.
     * @return purchasedWithinPeriod for account
     */
    function getPurchasedWithinPeriod(address account) external view appAdministratorOnly(appManagerAddress) returns (uint256) {
        return purchasedWithinPeriod[account];
    }

    /**
     * @dev Get the cumulative total of the Sales for account during sell period.
     * @return salesWithinPeriod for account
     */
    function getSalesWithinPeriod(address account) external view appAdministratorOnly(appManagerAddress) returns (uint256) {
        return salesWithinPeriod[account];
    }

    /**
     * @dev Set the minTransferRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinTransferRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        minTransferRuleId = _ruleId;
        minTransferRuleActive = true;
        emit ApplicationHandlerApplied(MIN_TRANSFER, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransferRule(bool _on) external appAdministratorOnly(appManagerAddress) {
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
    function setMinMaxBalanceRuleIdToken0(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleIdToken0 = _ruleId;
        minMaxBalanceRuleActive = true;
    }

    /**
     * @dev Set the minMaxBalanceRuleId for Token 1. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleIdToken1(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleIdToken1 = _ruleId;
        minMaxBalanceRuleActive = true;
        emit ApplicationHandlerApplied(MIN_MAX_BALANCE_LIMIT, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(bool _on) external appAdministratorOnly(appManagerAddress) {
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
    function setOracleRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        oracleRuleId = _ruleId;
        oracleRuleActive = true;
        emit ApplicationHandlerApplied(ORACLE, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateOracleRule(bool _on) external appAdministratorOnly(appManagerAddress) {
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
    function setAMMFeeRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        ammFeeRuleId = _ruleId;
        ammFeeRuleActive = true;
        emit ApplicationHandlerApplied(AMM_FEE, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param on_off boolean representing if a rule must be checked or not.
     */
    function activateAMMFeeRule(bool on_off) external appAdministratorOnly(appManagerAddress) {
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
}
