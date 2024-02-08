// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HandlerRuleContractsCommonImports.sol";
import {IAppManagerErrors } from "../../../../common/IErrors.sol";
import {ITokenHandlerEvents } from "../../../../common/IEvents.sol";
import "../../IAdminMinTokenBalanceCapable.sol";

/**
 * @title Handler Admin Min Token Balance 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerAdminMinTokenBalance is  HandlerRuleContractsCommonImports, IAppManagerErrors, ITokenHandlerEvents, RuleAdministratorOnly, IAdminMinTokenBalanceCapable {

    /// This is used to set the max action for an efficient check of all actions in the enum
    uint8 constant LAST_POSSIBLE_ACTION = uint8(ActionTypes.P2P_TRANSFER);

    /// Rule Setters and Getters
    /**
     * @dev Set the AdminMinTokenBalance. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setAdminMinTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAdminMinTokenBalance(_ruleId);
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (isAdminMinTokenBalanceActiveForAnyAction()) {
            if (isAdminMinTokenBalanceActiveAndApplicable()) revert AdminMinTokenBalanceisActive();
        }
        mapping(ActionTypes => Rule) storage adminMinTokenBalance = lib.adminMinTokenBalanceStorage().adminMinTokenBalance;
        for (uint i; i < _actions.length; ) {
            /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
            adminMinTokenBalance[_actions[i]].ruleId = _ruleId;
            adminMinTokenBalance[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(ADMIN_MIN_TOKEN_BALANCE, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev This function is used by the app manager to determine if the AdminMinTokenBalance rule is active for any actions
     * @return Success equals true if all checks pass
     */
    function isAdminMinTokenBalanceActiveAndApplicable() public view override returns (bool) {
        bool active;
        uint8 action = 0;
        mapping(ActionTypes => Rule) storage adminMinTokenBalance = lib.adminMinTokenBalanceStorage().adminMinTokenBalance;
        /// if the rule is active for any actions, set it as active and applicable.
        while (action <= LAST_POSSIBLE_ACTION) { 
            if (adminMinTokenBalance[ActionTypes(action)].active) {
                try IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAdminMinTokenBalance(adminMinTokenBalance[ActionTypes(action)].ruleId, 1, 1) {} catch {
                    active = true;
                    break;
                }
            }
            action++;
        }
        return active;
    }

    /**
     * @dev This function is used internally to check if the admin min token balance is active for any actions
     * @return Success equals true if all checks pass
     */
    function isAdminMinTokenBalanceActiveForAnyAction() internal view returns (bool) {
        bool active;
        uint8 action = 0;
        mapping(ActionTypes => Rule) storage adminMinTokenBalance = lib.adminMinTokenBalanceStorage().adminMinTokenBalance;
        /// if the rule is active for any actions, set it as active and applicable.
        while (action <= LAST_POSSIBLE_ACTION) { 
            if (adminMinTokenBalance[ActionTypes(action)].active) {
                active = true;
                break;
            }
            action++;
        }
        return active;
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
        for (uint i; i < _actions.length; ) {
            adminMinTokenBalance[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(ADMIN_MIN_TOKEN_BALANCE, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(ADMIN_MIN_TOKEN_BALANCE, _actions[i]);
            }
            unchecked {
                ++i;
            }
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

