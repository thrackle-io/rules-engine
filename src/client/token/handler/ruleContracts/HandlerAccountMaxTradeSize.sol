// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "src/client/token/handler/ruleContracts/HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Account Max Trade Size
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerAccountMaxTradeSize is RuleAdministratorOnly, ActionTypesArray, ITokenHandlerEvents, IAssetHandlerErrors {
    /// Rule Setters and Getters
    /**
     * @dev Retrieve the Account Max Trade Size Rule Id
     * @param _actions the action types
     * @return accountMaxTradeSizeId
     */
    function getAccountMaxTradeSizeId(ActionTypes _actions) external view returns (uint32) {
        return lib.accountMaxTradeSizeStorage().accountMaxTradeSize[_actions].ruleId;
    }

    /**
     * @dev Set the AccountMaxTradeSizeRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxTradeSizeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMaxTradeSize(_actions, _ruleId);
        resetAccountMaxTradeSize();
        for (uint i; i < _actions.length; ++i) {
            delete lib.accountMaxTradeSizeStorage().accountMaxTradeSize[_actions[i]];
            setAccountMaxTradeSizeIdUpdate(_actions[i], _ruleId);
            emit AD1467_ApplicationHandlerActionApplied(ACCOUNT_MAX_TRADE_SIZE, _actions[i], _ruleId);
        }
    }

    /**
     * @dev Set the AccountMaxTradeSizeRule suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @notice This function does not check that the array length is greater than zero to allow for clearing out of the action types data
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setAccountMaxTradeSizeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearAccountMaxTradeSize();
        for (uint i; i < _actions.length; ++i) {
            setAccountMaxTradeSizeIdUpdate(_actions[i], _ruleIds[i]);
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(ACCOUNT_MAX_TRADE_SIZE, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearAccountMaxTradeSize() internal {
        AccountMaxTradeSizeS storage data = lib.accountMaxTradeSizeStorage();
        resetAccountMaxTradeSize();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction;) {
            delete data.accountMaxTradeSize[ActionTypes(i)];
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Set the AccountMaxTradeSizeRuleId.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setAccountMaxTradeSizeIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        if (!(_action == ActionTypes.SELL || _action == ActionTypes.BUY)) revert InvalidAction();
        AccountMaxTradeSizeS storage data = lib.accountMaxTradeSizeStorage();
        data.accountMaxTradeSize[_action].ruleId = _ruleId;
        data.accountMaxTradeSize[_action].active = true;
    }

    /**
     * @dev reset the ruleChangeDate within the rule data struct. This will signal the rule check to clear the accumulator data prior to checking the rule.
     */
    function resetAccountMaxTradeSize() internal{

        AccountMaxTradeSizeS storage data = lib.accountMaxTradeSizeStorage();
        data.ruleChangeDate = block.timestamp;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action type to set the rule
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxTradeSize(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if(_on) resetAccountMaxTradeSize();
        for (uint i; i < _actions.length; ++i) {
            if (!(_actions[i] == ActionTypes.SELL || _actions[i] == ActionTypes.BUY)) revert InvalidAction();
            lib.accountMaxTradeSizeStorage().accountMaxTradeSize[_actions[i]].active = _on;
        }
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(ACCOUNT_MAX_TRADE_SIZE, _actions, 0);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(ACCOUNT_MAX_TRADE_SIZE, _actions, 0);
        }
    }

    /**
     * @dev Tells you if the Account Max Trade Size Rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isAccountMaxTradeSizeActive(ActionTypes _action) external view returns (bool) {
        return lib.accountMaxTradeSizeStorage().accountMaxTradeSize[_action].active;
    }
}
