// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Min Hold Time 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerTokenMinHoldTime is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors{

    uint16 constant MAX_HOLD_TIME_HOURS = 43830;

    /// -------------SIMPLE RULE SETTERS and GETTERS---------------
    /**
     * @dev Tells you if the minimum hold time rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMinHoldTime(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ) {
            lib.tokenMinHoldTimeStorage().tokenMinHoldTime[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MIN_HOLD_TIME, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MIN_HOLD_TIME, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Setter the minimum hold time rule hold hours
     * @param _actions the action types
     * @param _minHoldTimeHours minimum amount of time to hold the asset
     */
    function setTokenMinHoldTime(ActionTypes[] calldata _actions, uint32 _minHoldTimeHours) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_minHoldTimeHours == 0) revert ZeroValueNotPermited();
        if (_minHoldTimeHours > MAX_HOLD_TIME_HOURS) revert PeriodExceeds5Years();
        TokenMinHoldTimeS storage data = lib.tokenMinHoldTimeStorage();
        for (uint i; i < _actions.length; ) {
            data.tokenMinHoldTime[_actions[i]].period = _minHoldTimeHours;
            data.tokenMinHoldTime[_actions[i]].active = true;
            emit ApplicationHandlerSimpleActionApplied(TOKEN_MIN_HOLD_TIME, _actions[i], uint256(_minHoldTimeHours));
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Get the minimum hold time rule hold hours
     * @param _action the action type
     * @return period minimum amount of time to hold the asset
     */
    function getTokenMinHoldTimePeriod(ActionTypes _action) external view returns (uint32) {
        return lib.tokenMinHoldTimeStorage().tokenMinHoldTime[_action].period;
    }

    /**
     * @dev function to check if Minumum Hold Time is active
     * @param _action the action type
     * @return bool
     */
    function isTokenMinHoldTimeActive(ActionTypes _action) external view returns (bool) {
        return lib.tokenMinHoldTimeStorage().tokenMinHoldTime[_action].active;
    }

    
}

