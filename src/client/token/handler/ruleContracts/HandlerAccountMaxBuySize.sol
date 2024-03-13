// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";


/**
 * @title Handler Account Max Buy Size 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerAccountMaxBuySize is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors {

    /// Rule Setters and Getters
    /**
     * @dev Set the AccountMaxBuySizeRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxBuySizeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        setAccountMaxBuySizeIdUpdate(ActionTypes.BUY, _ruleId);
        emit AD1467_ApplicationHandlerActionApplied(ACCOUNT_MAX_BUY_SIZE, ActionTypes.BUY, _ruleId);
    }

    /**
     * @dev Set the AccountMaxBuySizeRule suite for all actions. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions all the actions to set the rule for
     * @param _ruleIds rule id's corresponding to each action
     */
    function setAccountMaxBuySizeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if(_actions.length == 0) revert InputArraysSizesNotValid();
        if(_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearAccountMaxBuySize();
        for (uint i; i < _actions.length; ) {
            setAccountMaxBuySizeIdUpdate(_actions[i], _ruleIds[i]);
            unchecked {
                ++i;
            }
        } 
         emit AD1467_ApplicationHandlerActionAppliedFull(ACCOUNT_MAX_BUY_SIZE, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearAccountMaxBuySize() internal {
        AccountMaxBuySizeS storage data = lib.accountMaxBuySizeStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction; ) {
            delete data.id;
            delete data.active;
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Set the AccountMaxBuySizeRuleId. 
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setAccountMaxBuySizeIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        if (_action != ActionTypes.BUY) revert InvalidAction();
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMaxBuySize(_ruleId);
        AccountMaxBuySizeS storage AccountMaxBuySize = lib.accountMaxBuySizeStorage();
        AccountMaxBuySize.id = _ruleId;
        AccountMaxBuySize.active = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxBuySize(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.accountMaxBuySizeStorage().active = _on;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.BUY;
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(ACCOUNT_MAX_BUY_SIZE, actionsArray);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(ACCOUNT_MAX_BUY_SIZE, actionsArray);
        }
    }

    /**
     * @dev Retrieve the Account Max Buy Size Rule Id
     * @return accountMaxBuySizeId
     */
    function getAccountMaxBuySizeId() external view returns (uint32) {
        return lib.accountMaxBuySizeStorage().id;
    }

    /**
     * @dev Tells you if the Account Max Buy Size Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountMaxBuySizeActive() external view returns (bool) {
        return lib.accountMaxBuySizeStorage().active;
    }



}

