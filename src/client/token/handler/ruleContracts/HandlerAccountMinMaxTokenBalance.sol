// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Account Min Max Token Balance
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerAccountMinMaxTokenBalance is RuleAdministratorOnly, ActionTypesArray, ITokenHandlerEvents, IAssetHandlerErrors {
    /// Rule Setters and Getters
    /**
     * @dev Set the accountMinMaxTokenBalanceRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setAccountMinMaxTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMinMaxTokenBalance(_actions, _ruleId);
        for (uint i; i < _actions.length; ++i) {
            setAccountMinMaxTokenBalanceIdUpdate(_actions[i], _ruleId);
            emit AD1467_ApplicationHandlerActionApplied(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions[i], _ruleId);
        }
    }

    /**
     * @dev Set the setAccountMinMaxTokenBalanceRule suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @notice This function does not check that the array length is greater than zero to allow for clearing out of the action types data
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setAccountMinMaxTokenBalanceIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearMinMaxTokenBalance();
        for (uint i; i < _actions.length; ++i) {
            // slither-disable-next-line calls-loop
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMinMaxTokenBalance(createActionTypesArray(_actions[i]), _ruleIds[i]);
            setAccountMinMaxTokenBalanceIdUpdate(_actions[i], _ruleIds[i]);
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearMinMaxTokenBalance() internal {
        AccountMinMaxTokenBalanceHandlerS storage data = lib.accountMinMaxTokenBalanceStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction;) {
            delete data.accountMinMaxTokenBalance[ActionTypes(i)];
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Set the AccountMaxMinMaxTokenBalanceRuleId.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setAccountMinMaxTokenBalanceIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMinMaxTokenBalance(createActionTypesArray(_action), _ruleId);
        AccountMinMaxTokenBalanceHandlerS storage data = lib.accountMinMaxTokenBalanceStorage();
        data.accountMinMaxTokenBalance[_action].ruleId = _ruleId;
        data.accountMinMaxTokenBalance[_action].active = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMinMaxTokenBalance(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ++i) {
            lib.accountMinMaxTokenBalanceStorage().accountMinMaxTokenBalance[_actions[i]].active = _on;
        }
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions);
        }
    }

    /**
     * Get the accountMinMaxTokenBalanceRuleId.
     * @param _action the action type
     * @return accountMinMaxTokenBalance rule id.
     */
    function getAccountMinMaxTokenBalanceId(ActionTypes _action) external view returns (uint32) {
        return lib.accountMinMaxTokenBalanceStorage().accountMinMaxTokenBalance[_action].ruleId;
    }

    /**
     * @dev Tells you if the AccountMinMaxTokenBalance is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isAccountMinMaxTokenBalanceActive(ActionTypes _action) external view returns (bool) {
        return lib.accountMinMaxTokenBalanceStorage().accountMinMaxTokenBalance[_action].active;
    }
}
