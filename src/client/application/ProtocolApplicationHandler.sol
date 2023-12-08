// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "src/client/application/AppManager.sol";
import "src/protocol/economic/AppAdministratorOnly.sol";
import "src/protocol/economic/ruleProcessor/RuleCodeData.sol";
import {IApplicationHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import "src/protocol/economic/IRuleProcessor.sol";
import "src/protocol/economic/ruleProcessor/ActionEnum.sol";
import {IZeroAddressError, IInputErrors} from "src/common/IErrors.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";

/**
 * @title Protocol ApplicationHandler Contract
 * @notice This contract is the rules handler for all application level rules. It is implemented via the AppManager
 * @dev This contract is injected into the appManagers.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract ProtocolApplicationHandler is Ownable, RuleAdministratorOnly, IApplicationHandlerEvents, ICommonApplicationHandlerEvents, IInputErrors, IZeroAddressError {
    string private constant VERSION="1.1.0";
    AppManager appManager;
    address public appManagerAddress;
    IRuleProcessor immutable ruleProcessor;

    /// Application level Rule Ids
    uint32 private accountBalanceByRiskRuleId;
    uint32 private maxTxSizePerPeriodByRiskRuleId;
    /// Application level Rule on-off switches
    bool private accountBalanceByRiskRuleActive;
    bool private maxTxSizePerPeriodByRiskActive;
    /// AccessLevel Rule Ids
    uint32 private accountBalanceByAccessLevelRuleId;
    uint32 private withdrawalLimitByAccessLevelRuleId;
    /// AccessLevel Rule on-off switches
    bool private accountBalanceByAccessLevelRuleActive;
    bool private AccessLevel0RuleActive;
    bool private withdrawalLimitByAccessLevelRuleActive;
    /// Pause Rule on-off switch
    bool private pauseRuleActive; 

    /// MaxTxSizePerPeriodByRisk data
    mapping(address => uint128) usdValueTransactedInRiskPeriod;
    mapping(address => uint64) lastTxDateRiskRule;
    /// AccessLevelWithdrawalRule data
    mapping(address => uint128) usdValueTotalWithrawals;

    /**
     * @dev Initializes the contract setting the AppManager address as the one provided and setting the ruleProcessor for protocol access
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress) {
        if (_ruleProcessorProxyAddress == address(0) || _appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = AppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        transferOwnership(_appManagerAddress);
        emit ApplicationHandlerDeployed(address(this), _appManagerAddress);
    }

    /**
     * @dev checks if any of the balance prerequisite rules are active
     * @return true if one or more rules are active
     */
    function requireValuations() public view returns (bool) {
        return accountBalanceByRiskRuleActive || accountBalanceByAccessLevelRuleActive || maxTxSizePerPeriodByRiskActive || withdrawalLimitByAccessLevelRuleActive;
    }

    /**
     * @dev Check Application Rules for valid transaction.
     * @param _action Action to be checked. This param is intentially added for future enhancements.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _usdBalanceTo recepient address current total application valuation in USD with 18 decimals of precision
     * @param _usdAmountTransferring valuation of the token being transferred in USD with 18 decimals of precision
     * @return success Returns true if allowed, false if not allowed
     */
    function checkApplicationRules(ActionTypes _action, address _from, address _to, uint128 _usdBalanceTo, uint128 _usdAmountTransferring) external onlyOwner returns (bool) {
        _action;
        if (pauseRuleActive) ruleProcessor.checkPauseRules(appManagerAddress);
        if (requireValuations() || AccessLevel0RuleActive) {
            _checkRiskRules(_from, _to, _usdBalanceTo, _usdAmountTransferring);
            _checkAccessLevelRules(_from, _to, _usdBalanceTo, _usdAmountTransferring);
        }
        return true;
    }

    /**
     * @dev This function consolidates all the Risk rules that utilize application level Risk rules.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _usdBalanceTo recepient address current total application valuation in USD with 18 decimals of precision
     * @param _usdAmountTransferring valuation of the token being transferred in USD with 18 decimals of precision
     */
    function _checkRiskRules(address _from, address _to, uint128 _usdBalanceTo, uint128 _usdAmountTransferring) internal {
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);
        if (accountBalanceByRiskRuleActive) {
            ruleProcessor.checkAccBalanceByRisk(accountBalanceByRiskRuleId, _to, riskScoreTo, _usdBalanceTo, _usdAmountTransferring);
        }
        if (maxTxSizePerPeriodByRiskActive) {
            /// if rule is active check if the recipient is address(0) for burning tokens
            /// check if sender violates the rule
            usdValueTransactedInRiskPeriod[_from] = ruleProcessor.checkMaxTxSizePerPeriodByRisk(
                maxTxSizePerPeriodByRiskRuleId,
                usdValueTransactedInRiskPeriod[_from],
                _usdAmountTransferring,
                lastTxDateRiskRule[_from],
                riskScoreFrom
            );
            if (_to != address(0)) {
                lastTxDateRiskRule[_from] = uint64(block.timestamp);
                /// check if recipient violates the rule
                usdValueTransactedInRiskPeriod[_to] = ruleProcessor.checkMaxTxSizePerPeriodByRisk(
                    maxTxSizePerPeriodByRiskRuleId,
                    usdValueTransactedInRiskPeriod[_to],
                    _usdAmountTransferring,
                    lastTxDateRiskRule[_to],
                    riskScoreTo
                );
                // set the last timestamp of check
                lastTxDateRiskRule[_to] = uint64(block.timestamp);
            }
        }
    }

    /**
     * @dev This function consolidates all the application level AccessLevel rules.
     * @param _to address of the to account
     * @param _usdBalanceValuation address current balance in USD
     * @param _usdAmountTransferring number of tokens transferred
     */
    function _checkAccessLevelRules(address _from, address _to, uint128 _usdBalanceValuation, uint128 _usdAmountTransferring) internal {
        uint8 score = appManager.getAccessLevel(_to);
        uint8 fromScore = appManager.getAccessLevel(_from);
        /// Check if sender is not AMM and then check sender access level
        if (AccessLevel0RuleActive && !appManager.isRegisteredAMM(_from)) ruleProcessor.checkAccessLevel0Passes(fromScore);
        /// Check if receiver is not an AMM or address(0) and then check the recipient access level. Exempting address(0) allows for burning.
        if (AccessLevel0RuleActive && !appManager.isRegisteredAMM(_to) && _to != address(0)) ruleProcessor.checkAccessLevel0Passes(score);
        /// Check that the recipient is not address(0). If it is we do not check this rule as it is a burn.
        if (accountBalanceByAccessLevelRuleActive && _to != address(0))
            ruleProcessor.checkAccBalanceByAccessLevel(accountBalanceByAccessLevelRuleId, score, _usdBalanceValuation, _usdAmountTransferring);
        if (withdrawalLimitByAccessLevelRuleActive) {
            usdValueTotalWithrawals[_from] = ruleProcessor.checkwithdrawalLimitsByAccessLevel(withdrawalLimitByAccessLevelRuleId, fromScore, usdValueTotalWithrawals[_from], _usdAmountTransferring);
        }
    }

    /**
     * @dev Set the accountBalanceByRiskRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountBalanceByRiskRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccBalanceByRisk(_ruleId);
        accountBalanceByRiskRuleId = _ruleId;
        accountBalanceByRiskRuleActive = true;
        emit ApplicationRuleApplied(BALANCE_BY_RISK, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountBalanceByRiskRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountBalanceByRiskRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(BALANCE_BY_RISK, address(this));
        } else {
            emit ApplicationHandlerDeactivated(BALANCE_BY_RISK, address(this));
        }
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
    function setAccountBalanceByAccessLevelRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccBalanceByAccessLevel(_ruleId);
        accountBalanceByAccessLevelRuleId = _ruleId;
        accountBalanceByAccessLevelRuleActive = true;
        emit ApplicationRuleApplied(BALANCE_BY_ACCESSLEVEL, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountBalanceByAccessLevelRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountBalanceByAccessLevelRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(BALANCE_BY_ACCESSLEVEL, address(this));
        } else {
            emit ApplicationHandlerDeactivated(BALANCE_BY_ACCESSLEVEL, address(this));
        }
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
    function getAccountBalanceByAccessLevelRule() external view returns (uint32) {
        return accountBalanceByAccessLevelRuleId;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccessLevel0Rule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        AccessLevel0RuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ACCESS_LEVEL_0, address(this));
        } else {
            emit ApplicationHandlerDeactivated(ACCESS_LEVEL_0, address(this));
        }
    }

    /**
     * @dev Tells you if the AccessLevel0 Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccessLevel0Active() external view returns (bool) {
        return AccessLevel0RuleActive;
    }

    /**
     * @dev Set the withdrawalLimitByAccessLevelRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setWithdrawalLimitByAccessLevelRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateWithdrawalLimitsByAccessLevel(_ruleId);
        withdrawalLimitByAccessLevelRuleId = _ruleId;
        withdrawalLimitByAccessLevelRuleActive = true;
        emit ApplicationRuleApplied(ACCESS_LEVEL_WITHDRAWAL, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateWithdrawalLimitByAccessLevelRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        withdrawalLimitByAccessLevelRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ACCESS_LEVEL_WITHDRAWAL, address(this));
        } else {
            emit ApplicationHandlerDeactivated(ACCESS_LEVEL_WITHDRAWAL, address(this));
        }
    }

    /**
     * @dev Tells you if the withdrawalLimitByAccessLevelRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isWithdrawalLimitByAccessLevelActive() external view returns (bool) {
        return withdrawalLimitByAccessLevelRuleActive;
    }

    /**
     * @dev Retrieve the withdrawalLimitByAccessLevel rule id
     * @return withdrawalLimitByAccessLevelRuleId rule id
     */
    function getWithdrawalLimitByAccessLevelRule() external view returns (uint32) {
        return withdrawalLimitByAccessLevelRuleId;
    }

    /**
     * @dev Retrieve the MaxTxSizePerPeriodByRisk rule id
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
    function setMaxTxSizePerPeriodByRiskRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMaxTxSizePerPeriodByRisk(_ruleId);
        maxTxSizePerPeriodByRiskRuleId = _ruleId;
        maxTxSizePerPeriodByRiskActive = true;
        emit ApplicationRuleApplied(MAX_TX_PER_PERIOD, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */

    function activateMaxTxSizePerPeriodByRiskRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        maxTxSizePerPeriodByRiskActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MAX_TX_PER_PERIOD, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MAX_TX_PER_PERIOD, address(this));
        }
    }

    /**
     * @dev Tells you if the MaxTxSizePerPeriodByRisk is active or not.
     * @return boolean representing if the rule is active for specified token
     */
    function isMaxTxSizePerPeriodByRiskActive() external view returns (bool) {
        return maxTxSizePerPeriodByRiskActive;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * This function does not use ruleAdministratorOnly modifier, the onlyOwner modifier checks that the caller is the appManager contract. 
     * @notice This function uses the onlyOwner modifier since the appManager contract is calling this function when adding a pause rule or removing the final pause rule of the array. 
     * @param _on boolean representing if a rule must be checked or not.
     */

    function activatePauseRule(bool _on) external onlyOwner {
        pauseRuleActive = _on; 
        if (_on) {
            emit ApplicationHandlerActivated(PAUSE_RULE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(PAUSE_RULE, address(this));
        }
    }

    /**
     * @dev Tells you if the pause rule check is active or not.
     * @return boolean representing if the rule is active for specified token
     */
    function isPauseRuleActive() external view returns (bool) {
        return pauseRuleActive;
    }

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }
}
