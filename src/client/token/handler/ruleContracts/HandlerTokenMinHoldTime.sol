// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/client/token/handler/ruleContracts/HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Min Hold Time
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerTokenMinHoldTime is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors {
    uint16 constant MAX_HOLD_TIME_HOURS = 43830;

    /// -------------SIMPLE RULE SETTERS and GETTERS---------------
    /**
     * @dev Tells you if the minimum hold time rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMinHoldTime(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (!_on) resetTokenMinHoldTime();
        for (uint i; i < _actions.length; ++i) {
            lib.tokenMinHoldTimeStorage().tokenMinHoldTime[_actions[i]].active = _on;
        }
        // if any actions remain on for this rule, then set the anyActionActive to true, otherwise set to false
        if (!_on){
            lib.tokenMinHoldTimeStorage().anyActionActive = false;
            for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction; ++i) {
                if (lib.tokenMinHoldTimeStorage().tokenMinHoldTime[_actions[i]].active){
                    lib.tokenMinHoldTimeStorage().anyActionActive = true;
                    break;
                }
            } 
        }
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(TOKEN_MIN_HOLD_TIME, _actions, 0);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(TOKEN_MIN_HOLD_TIME, _actions, 0);
        }
    }

    /**
     * @dev Set the TokenMinHoldTime. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _minHoldTimeHours min hold time in hours
     */
    function setTokenMinHoldTime(ActionTypes[] calldata _actions, uint32 _minHoldTimeHours) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        resetTokenMinHoldTime();
        for (uint i; i < _actions.length; ++i) {
            setTokenMinHoldTimeIdUpdate(_actions[i], _minHoldTimeHours);
            emit AD1467_ApplicationHandlerActionApplied(TOKEN_MIN_HOLD_TIME, _actions[i], _minHoldTimeHours);
        }
    }

    /**
     * @dev Set the setTokenMinHoldTimeRule suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @notice This function does not check that the array length is greater than zero to allow for clearing out of the action types data
     * @param _actions actions to have the rule applied to
     * @param _minHoldTimeHours min hold time in hours corresponding to the actions
     */
    function setTokenMinHoldTimeFull(ActionTypes[] calldata _actions, uint32[] calldata _minHoldTimeHours) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length != _minHoldTimeHours.length) revert InputArraysMustHaveSameLength();
        clearTokenMinHoldTime();
        for (uint i; i < _actions.length; ++i) {
            setTokenMinHoldTimeIdUpdate(_actions[i], _minHoldTimeHours[i]);
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(TOKEN_MIN_HOLD_TIME, _actions, _minHoldTimeHours);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMinHoldTime() internal {
        TokenMinHoldTimeS storage data = lib.tokenMinHoldTimeStorage();
        resetTokenMinHoldTime();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction;) {
            delete data.tokenMinHoldTime[ActionTypes(i)];
            unchecked {
                ++i;
            }
        }
    }
   
    /**
     * @dev reset the ruleChangeDate within the rule data struct. This will signal the rule check to clear the accumulator data prior to checking the rule.
     */
    function resetTokenMinHoldTime() internal{
        TokenMinHoldTimeS storage data = lib.tokenMinHoldTimeStorage();
        data.ruleChangeDate = block.timestamp;
    }

    /**
     * @dev Set the TokenMinHoldTime.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _minHoldTimeHours the min hold time in hours
     */
    function setTokenMinHoldTimeIdUpdate(ActionTypes _action, uint32 _minHoldTimeHours) internal {
        if (_minHoldTimeHours == 0) revert ZeroValueNotPermited();
        if (_minHoldTimeHours > MAX_HOLD_TIME_HOURS) revert PeriodExceeds5Years();
        TokenMinHoldTimeS storage data = lib.tokenMinHoldTimeStorage();
        data.tokenMinHoldTime[_action].period = _minHoldTimeHours;
        data.tokenMinHoldTime[_action].active = true;
        data.anyActionActive = true;
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
