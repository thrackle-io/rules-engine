// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";


/**
 * @title Handler Account Max Sell Size 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerAccountMaxSellSize is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors{

    /// Rule Setters and Getters
    /**
     * @dev Set the AccountMaxSellSizeRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxSellSizeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        setAccountMaxSellSizeIdUpdate(ActionTypes.SELL, _ruleId);
        emit AD1467_ApplicationHandlerActionApplied(ACCOUNT_MAX_SELL_SIZE, ActionTypes.SELL, _ruleId);
    }

    /**
     * @dev Set the AccountMaxSellSizeRule suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setAccountMaxSellSizeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if(_actions.length == 0) revert InputArraysSizesNotValid();
        if(_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearAccountMaxSellSize();
        for (uint i; i < _actions.length; ) {
            setAccountMaxSellSizeIdUpdate(_actions[i], _ruleIds[i]);
            unchecked {
                ++i;
            }
        } 
         emit AD1467_ApplicationHandlerActionAppliedFull(ACCOUNT_MAX_SELL_SIZE, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearAccountMaxSellSize() internal {
        AccountMaxSellSizeS storage data = lib.accountMaxSellSizeStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction; ) {
            delete data.id;
            delete data.active;
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Set the AccountMaxSellSizeRuleId. 
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxSellSizeIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        if (_action != ActionTypes.SELL) revert InvalidAction();
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMaxSellSize(_ruleId);
        AccountMaxSellSizeS storage AccountMaxSellSize = lib.accountMaxSellSizeStorage();
        AccountMaxSellSize.id = _ruleId;
        AccountMaxSellSize.active = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxSellSize(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.accountMaxSellSizeStorage().active = _on;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.SELL;
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(ACCOUNT_MAX_SELL_SIZE, actionsArray);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(ACCOUNT_MAX_SELL_SIZE, actionsArray);
        }
    }

    /**
     * @dev Retrieve the Account Max Sell Size Rule Id
     * @return accountMaxSellSizeId
     */
    function getAccountMaxSellSizeId() external view returns (uint32) {
        return lib.accountMaxSellSizeStorage().id;
    }

    /**
     * @dev Tells you if the Account Max Sell Size Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountMaxSellSizeActive() external view returns (bool) {
        return lib.accountMaxSellSizeStorage().active;
    }



}

