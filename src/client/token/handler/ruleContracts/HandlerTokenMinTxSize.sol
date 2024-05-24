// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/client/token/handler/ruleContracts/HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Min Tx Size
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerTokenMinTxSize is RuleAdministratorOnly, ActionTypesArray, ITokenHandlerEvents, IAssetHandlerErrors {
    /// Rule Setters and Getters

    /**
     * @dev Set the TokenMinTxSize. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setTokenMinTxSizeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMinTxSize(_actions, _ruleId);
        for (uint i; i < _actions.length; ++i) {
            setTokenMinTxSizeIdUpdate(_actions[i], _ruleId);
            emit AD1467_ApplicationHandlerActionApplied(TOKEN_MIN_TX_SIZE, _actions[i], _ruleId);
        }
    }

    /**
     * @dev Set the setTokenMinTxSizeRule suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @notice This function does not check that the array length is greater than zero to allow for clearing out of the action types data
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setTokenMinTxSizeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearTokenMinTxSize();
        for (uint i; i < _actions.length; ++i) {
            // slither-disable-next-line calls-loop
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMinTxSize(createActionTypesArray(_actions[i]), _ruleIds[i]);
            setTokenMinTxSizeIdUpdate(_actions[i], _ruleIds[i]);
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(TOKEN_MIN_TX_SIZE, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMinTxSize() internal {
        TokenMinTxSizeS storage data = lib.tokenMinTxSizeStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction;) {
            delete data.tokenMinTxSize[ActionTypes(i)];
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Set the TokenMinTxSize.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setTokenMinTxSizeIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMinTxSize(createActionTypesArray(_action), _ruleId);
        TokenMinTxSizeS storage data = lib.tokenMinTxSizeStorage();
        data.tokenMinTxSize[_action].ruleId = _ruleId;
        data.tokenMinTxSize[_action].active = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action type
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransactionSizeRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ++i) {
            lib.tokenMinTxSizeStorage().tokenMinTxSize[_actions[i]].active = _on;
        }

        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(TOKEN_MIN_TX_SIZE, _actions);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(TOKEN_MIN_TX_SIZE, _actions);
        }
    }

    /**
     * @dev Retrieve the tokenMinTxSizeRuleId
     * @param _action the action type
     * @return tokenMinTransactionRuleId
     */
    function getTokenMinTxSizeId(ActionTypes _action) external view returns (uint32) {
        return lib.tokenMinTxSizeStorage().tokenMinTxSize[_action].ruleId;
    }

    /**
     * @dev Tells you if the TokenMinTxSizeRule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMinTxSizeActive(ActionTypes _action) external view returns (bool) {
        return lib.tokenMinTxSizeStorage().tokenMinTxSize[_action].active;
    }
}
