// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Daily Trades
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerTokenMaxDailyTrades is RuleAdministratorOnly, ActionTypesArray, ITokenHandlerEvents, IAssetHandlerErrors {
    /// Rule Setters and Getters

    /**
     * @dev Set the TokenMaxDailyTrades. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxDailyTradesId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxDailyTrades(_actions, _ruleId);
        for (uint i; i < _actions.length; ++i) {
            setTokenMaxDailyTradesIdUpdate(_actions[i], _ruleId);
            emit AD1467_ApplicationHandlerActionApplied(TOKEN_MAX_DAILY_TRADES, _actions[i], _ruleId);
        }
    }

    /**
     * @dev Set the setTokenMaxDailyTrades Rule suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setTokenMaxDailyTradesIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearTokenMaxDailyTrades();
        for (uint i; i < _actions.length; ++i) {
            // slither-disable-next-line calls-loop
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxDailyTrades(createActionTypesArray(_actions[i]), _ruleIds[i]);
            setTokenMaxDailyTradesIdUpdate(_actions[i], _ruleIds[i]);
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(TOKEN_MAX_DAILY_TRADES, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMaxDailyTrades() internal {
        TokenMaxDailyTradesS storage data = lib.tokenMaxDailyTradesStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction;) {
            delete data.tokenMaxDailyTrades[ActionTypes(i)];
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Set the TokenMaxDailyTrades.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setTokenMaxDailyTradesIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        if (_action == ActionTypes.BURN) revert InvalidAction(); 
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxDailyTrades(createActionTypesArray(_action), _ruleId);
        TokenMaxDailyTradesS storage data = lib.tokenMaxDailyTradesStorage();
        data.tokenMaxDailyTrades[_action].ruleId = _ruleId;
        data.tokenMaxDailyTrades[_action].active = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxDailyTrades(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ++i) {
            if (_actions[i] == ActionTypes.BURN) revert InvalidAction(); 
            lib.tokenMaxDailyTradesStorage().tokenMaxDailyTrades[_actions[i]].active = _on;
        }
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(TOKEN_MAX_DAILY_TRADES, _actions);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(TOKEN_MAX_DAILY_TRADES, _actions);
        }
    }

    /**
     * @dev Retrieve the token max daily trades rule id
     * @param _action the action type
     * @return tokenMaxDailyTradesRuleId
     */
    function getTokenMaxDailyTradesId(ActionTypes _action) external view returns (uint32) {
        return lib.tokenMaxDailyTradesStorage().tokenMaxDailyTrades[_action].ruleId;
    }

    /**
     * @dev Tells you if the tokenMaxDailyTradesRule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMaxDailyTradesActive(ActionTypes _action) external view returns (bool) {
        return lib.tokenMaxDailyTradesStorage().tokenMaxDailyTrades[_action].active;
    }
}
