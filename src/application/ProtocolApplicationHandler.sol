// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "src/economic/ruleProcessor/RuleProcessorDiamondLib.sol";
import "../application/AppManager.sol";
import "../economic/AppAdministratorOnly.sol";
import {IAppLevelEvents} from "../interfaces/IEvents.sol";
import "../economic/IRuleProcessor.sol";

/**
 * @title Protocol ApplicationHandler Contract
 * @notice This contract is the rules handler for all application level rules. It is implemented via the AppManager
 * @dev This contract is injected into the appManagerss.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract ProtocolApplicationHandler is Ownable, AppAdministratorOnly, IAppLevelEvents {
    AppManager appManager;
    address appManagerAddress;
    IRuleProcessor immutable ruleProcessor;

    error ZeroAddress();

    /// Application Risk and AccessLevel rule Ids
    /// Risk Rule Ids
    uint32 private accountBalanceByRiskRuleId;
    uint32 private maxTxSizePerPeriodByRiskRuleId;
    /// Risk Rule on-off switches
    bool private accountBalanceByRiskRuleActive;
    bool private maxTxSizePerPeriodByRiskActive;
    /// AccessLevel Rule Id
    uint32 private accountBalanceByAccessLevelRuleId;
    /// AccessLevel Rule on-off switch
    bool private accountBalanceByAccessLevelRuleActive;
    bool private AccessLevel0RuleActive;

    /// MaxTxSizePerPeriodByRisk data
    mapping(address => uint128) usdValueTransactedInRiskPeriod;
    mapping(address => uint64) lastTxDateRiskRule;

    /**
     * @dev Initializes the contract setting the owner as the one provided.
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress) {
        appManagerAddress = _appManagerAddress;
        appManager = AppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        emit ApplicationHandlerDeployed(address(this));
    }

    /**
     * @dev checks if any of the AccessLevel or Risk rules are active
     * @return true if one or more rules are active
     */
    function riskOrAccessLevelRulesActive() external view returns (bool) {
        return accountBalanceByRiskRuleActive || accountBalanceByAccessLevelRuleActive || AccessLevel0RuleActive || maxTxSizePerPeriodByRiskActive;
    }

    /**
     * @dev Check Application Rules for valid transaction.
     * @param _action Action to be checked
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _usdBalanceTo recepient address current total application valuation in USD with 18 decimals of precision
     * @param _usdAmountTransferring valuation of the token being transferred in USD with 18 decimals of precision
     * @return success Returns true if allowed, false if not allowed
     */
    function checkApplicationRules(RuleProcessorDiamondLib.ActionTypes _action, address _from, address _to, uint128 _usdBalanceTo, uint128 _usdAmountTransferring) external returns (bool) {
        _action;
        ruleProcessor.checkPauseRules(appManagerAddress);
        if (accountBalanceByRiskRuleActive || accountBalanceByAccessLevelRuleActive || AccessLevel0RuleActive || maxTxSizePerPeriodByRiskActive) {
            _checkRiskRules(_from, _to, _usdBalanceTo, _usdAmountTransferring);
            _checkAccessLevelRules(_from, _to, _usdBalanceTo, _usdAmountTransferring);
        }
        return true;
    }

    /**
     * @dev This function consolidates all the Risk rules that utilize tagged account Risk scores.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _usdBalanceTo recepient address current total application valuation in USD with 18 decimals of precision
     * @param _usdAmountTransferring valuation of the token being transferred in USD with 18 decimals of precision
     */
    function _checkRiskRules(address _from, address _to, uint128 _usdBalanceTo, uint128 _usdAmountTransferring) internal {
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);
        if (accountBalanceByRiskRuleActive) {
            ruleProcessor.checkAccBalanceByRisk(accountBalanceByRiskRuleId, riskScoreTo, _usdBalanceTo, _usdAmountTransferring);
        }
        if (maxTxSizePerPeriodByRiskActive) {
            /// we check for sender
            usdValueTransactedInRiskPeriod[_from] = ruleProcessor.checkMaxTxSizePerPeriodByRisk(
                maxTxSizePerPeriodByRiskRuleId,
                usdValueTransactedInRiskPeriod[_from],
                _usdAmountTransferring,
                lastTxDateRiskRule[_from],
                riskScoreFrom
            );
            lastTxDateRiskRule[_from] = uint64(block.timestamp);
            /// we check for recipient
            usdValueTransactedInRiskPeriod[_to] = ruleProcessor.checkMaxTxSizePerPeriodByRisk(
                maxTxSizePerPeriodByRiskRuleId,
                usdValueTransactedInRiskPeriod[_to],
                _usdAmountTransferring,
                lastTxDateRiskRule[_to],
                riskScoreTo
            );
            lastTxDateRiskRule[_to] = uint64(block.timestamp);
        }
    }

    /**
     * @dev This function consolidates all the AccessLevel rules that utilize tagged account AccessLevel scores.
     * @param _to address of the to account
     * @param _balanceValuation address current balance in USD
     * @param _amount number of tokens transferred
     */
    function _checkAccessLevelRules(address _from, address _to, uint128 _balanceValuation, uint128 _amount) internal view {
        uint8 score = appManager.getAccessLevel(_to);
        uint8 fromScore = appManager.getAccessLevel(_from);
        if (AccessLevel0RuleActive && appManager.isRegisteredAMM(_to)) ruleProcessor.checkAccessLevel0Passes(fromScore);
        if (AccessLevel0RuleActive && !appManager.isRegisteredAMM(_to)) ruleProcessor.checkAccessLevel0Passes(score);
        if (accountBalanceByAccessLevelRuleActive) ruleProcessor.checkAccBalanceByAccessLevel(accountBalanceByAccessLevelRuleId, score, _balanceValuation, _amount);
    }

    /**
     * @dev Set the accountBalanceByRiskRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountBalanceByRiskRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        accountBalanceByRiskRuleId = _ruleId;
        accountBalanceByRiskRuleActive = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountBalanceByRiskRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        accountBalanceByRiskRuleActive = _on;
    }

    /**
     * @dev Tells you if the accountBalanceByRiskRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountBalanceByRiskActive() external view returns (bool) {
        return accountBalanceByRiskRuleActive;
    }

    /**
     * @dev Retrieve the accountBalanceByRisk rule id
     * @return accountBalanceByRiskRuleId rule id
     */
    function getAccountBalanceByRiskRule() external view returns (uint32) {
        return accountBalanceByRiskRuleId;
    }

    /**
     * @dev Set the accountBalanceByAccessLevelRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountBalanceByAccessLevelRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        accountBalanceByAccessLevelRuleId = _ruleId;
        accountBalanceByAccessLevelRuleActive = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountBalanceByAccessLevelRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        accountBalanceByAccessLevelRuleActive = _on;
    }

    /**
     * @dev Tells you if the accountBalanceByAccessLevelRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountBalanceByAccessLevelActive() external view returns (bool) {
        return accountBalanceByAccessLevelRuleActive;
    }

    /**
     * @dev Retrieve the accountBalanceByAccessLevel rule id
     * @return accountBalanceByAccessLevelRuleId rule id
     */
    function getAccountBalanceByAccessLevelkRule() external view returns (uint32) {
        return accountBalanceByAccessLevelRuleId;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccessLevel0Rule(bool _on) external appAdministratorOnly(appManagerAddress) {
        AccessLevel0RuleActive = _on;
    }

    /**
     * @dev Tells you if the AccessLevel0 Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccessLevel0Active() external view returns (bool) {
        return AccessLevel0RuleActive;
    }

    /**
     * @dev Retrieve the oracle rule id
     * @return MaxTxSizePerPeriodByRisk rule id for specified token
     */
    function getMaxTxSizePerPeriodByRiskRuleId() external view returns (uint32) {
        return maxTxSizePerPeriodByRiskRuleId;
    }

    /**
     * @dev Set the MaxTxSizePerPeriodByRisk. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMaxTxSizePerPeriodByRiskRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        maxTxSizePerPeriodByRiskRuleId = _ruleId;
        maxTxSizePerPeriodByRiskActive = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */

    function activateMaxTxSizePerPeriodByRiskRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        maxTxSizePerPeriodByRiskActive = _on;
    }

    /**
     * @dev Tells you if the MaxTxSizePerPeriodByRisk is active or not.
     * @return boolean representing if the rule is active for specified token
     */
    function isMaxTxSizePerPeriodByRiskActive() external view returns (bool) {
        return maxTxSizePerPeriodByRiskActive;
    }
}
