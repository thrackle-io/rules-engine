// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Trading Volume 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerTokenMinTxSize is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors{

    /// Rule Setters and Getters
    
    /**
     * @dev Set the tokenMinTransactionRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setTokenMinTxSizeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        TokenMinTxSizeS storage data = lib.tokenMinTxSizeStorage();
        for (uint i; i < _actions.length; ) {
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMinTxSize(_ruleId);
            data.tokenMinTxSize[_actions[i]].ruleId = _ruleId;
            data.tokenMinTxSize[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(TOKEN_MIN_TX_SIZE, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action type
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransactionSizeRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ) {
            lib.tokenMinTxSizeStorage().tokenMinTxSize[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MIN_TX_SIZE, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MIN_TX_SIZE, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Retrieve the tokenMinTransactionRuleId
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

