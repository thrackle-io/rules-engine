// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAppManagerErrors, IInputErrors} from "../../../../common/IErrors.sol";
import {ITokenHandlerEvents} from "../../../../common/IEvents.sol";
import "../../IAdminMinTokenBalanceCapable.sol";
import {IInputErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Admin Min Token Balance
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerAdminMinTokenBalance is ActionTypesArray, IAppManagerErrors, ITokenHandlerEvents, RuleAdministratorOnly, IAdminMinTokenBalanceCapable, IInputErrors {
    /// Rule Setters and Getters
    /**
     * @dev Set the AdminMinTokenBalance. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setAdminMinTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAdminMinTokenBalance(_actions, _ruleId);
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (isAdminMinTokenBalanceActiveForAnyAction()) {
            if (isAdminMinTokenBalanceActiveAndApplicable()) revert AdminMinTokenBalanceisActive();
        }
        for (uint i; i < _actions.length; ++i) {
            /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
            setAdminMinTokenBalanceIdUpdate(_actions[i], _ruleId);
            emit AD1467_ApplicationHandlerActionApplied(ADMIN_MIN_TOKEN_BALANCE, _actions[i], _ruleId);
        }
    }

    /**
     * @dev Set the setAdminMinTokenBalance suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setAdminMinTokenBalanceIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length == 0) revert InputArraysSizesNotValid();
        if (_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearAdminMinTokenBalance();
        for (uint i; i < _actions.length; ++i) {
            // slither-disable-next-line calls-loop
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAdminMinTokenBalance(createActionTypesArray(_actions[i]), _ruleIds[i]);
            setAdminMinTokenBalanceIdUpdate(_actions[i], _ruleIds[i]);
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(ADMIN_MIN_TOKEN_BALANCE, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearAdminMinTokenBalance() internal {
        AdminMinTokenBalanceS storage data = lib.adminMinTokenBalanceStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction; ++i) {
            delete data.adminMinTokenBalance[ActionTypes(i)];
        }
    }

    /**
     * @dev Set the AdminMinTokenBalance.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setAdminMinTokenBalanceIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAdminMinTokenBalance(createActionTypesArray(_action), _ruleId);
        AdminMinTokenBalanceS storage data = lib.adminMinTokenBalanceStorage();
        data.adminMinTokenBalance[_action].ruleId = _ruleId;
        data.adminMinTokenBalance[_action].active = true;
    }

    /**
     * @dev This function is used by the app manager to determine if the AdminMinTokenBalance rule is active for any actions
     * @return Success equals true if all checks pass
     */
    // Disabling this finding, the necessary data for the checks lives in two different facets so the external calls to another
    // facet inside of a loop are required here.
    // slither-disable-next-line calls-loop
    function isAdminMinTokenBalanceActiveAndApplicable() public view override returns (bool) {
        uint8 action = 0;
        mapping(ActionTypes => Rule) storage adminMinTokenBalance = lib.adminMinTokenBalanceStorage().adminMinTokenBalance;
        /// if the rule is active for any actions, set it as active and applicable.
        while (action <= lib.handlerBaseStorage().lastPossibleAction) {
            if (adminMinTokenBalance[ActionTypes(action)].active) {
                try IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAdminMinTokenBalance(adminMinTokenBalance[ActionTypes(action)].ruleId, 1, 1) {} catch {
                    return true;
                }
            }
            action++;
        }
        return false;
    }

    /**
     * @dev This function is used internally to check if the admin min token balance is active for any actions
     * @return Success equals true if all checks pass
     */
    function isAdminMinTokenBalanceActiveForAnyAction() internal view returns (bool) {
        uint8 action = 0;
        mapping(ActionTypes => Rule) storage adminMinTokenBalance = lib.adminMinTokenBalanceStorage().adminMinTokenBalance;
        /// if the rule is active for any actions, set it as active and applicable.
        while (action <= lib.handlerBaseStorage().lastPossibleAction) {
            if (adminMinTokenBalance[ActionTypes(action)].active) {
                return true;
            }
            action++;
        }
        return false;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action type
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAdminMinTokenBalance(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            if (isAdminMinTokenBalanceActiveAndApplicable()) revert AdminMinTokenBalanceisActive();
        }
        mapping(ActionTypes => Rule) storage adminMinTokenBalance = lib.adminMinTokenBalanceStorage().adminMinTokenBalance;
        for (uint i; i < _actions.length; ++i) {
            adminMinTokenBalance[_actions[i]].active = _on;
        }
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(ADMIN_MIN_TOKEN_BALANCE, _actions);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(ADMIN_MIN_TOKEN_BALANCE, _actions);
        }
    }

    /**
     * @dev Tells you if the admin min token balance rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isAdminMinTokenBalanceActive(ActionTypes _action) external view returns (bool) {
        return lib.adminMinTokenBalanceStorage().adminMinTokenBalance[_action].active;
    }

    /**
     * @dev Retrieve the admin min token balance rule id
     * @param _action the action type
     * @return adminMinTokenBalanceRuleId rule id
     */
    function getAdminMinTokenBalanceId(ActionTypes _action) external view returns (uint32) {
        return lib.adminMinTokenBalanceStorage().adminMinTokenBalance[_action].ruleId;
    }
}
