// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Daily Trades
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerTokenMaxDailyTrades is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors{

    /// Rule Setters and Getters

    /**
     * @dev Set the tokenMaxDailyTradesRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxDailyTradesId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {       
        TokenMaxDailyTradesS storage data = lib.tokenMaxDailyTradesStorage();
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxDailyTrades(_ruleId);
        for (uint i; i < _actions.length; ) {
            data.tokenMaxDailyTrades[_actions[i]].ruleId = _ruleId;
            data.tokenMaxDailyTrades[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(TOKEN_MAX_DAILY_TRADES, _actions[i], _ruleId);
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
    function activateTokenMaxDailyTrades(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ) {
            lib.tokenMaxDailyTradesStorage().tokenMaxDailyTrades[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MAX_DAILY_TRADES, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MAX_DAILY_TRADES, _actions[i]);
            }
            unchecked {
                ++i;
            }
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

