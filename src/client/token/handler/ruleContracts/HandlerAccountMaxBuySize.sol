// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HandlerRuleContractsCommonImports.sol";


/**
 * @title Handler Account Max Buy Size 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerAccountMaxBuySize is RuleAdministratorOnly, ITokenHandlerEvents{

    /// Rule Setters and Getters
    /**
     * @dev Set the AccountMaxBuySizeRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxBuySizeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMaxBuySize(_ruleId);
        AccountMaxBuySizeS storage AccountMaxBuySize = lib.accountMaxBuySizeStorage();
        AccountMaxBuySize.id = _ruleId;
        AccountMaxBuySize.active = true;
        emit ApplicationHandlerActionApplied(ACCOUNT_MAX_BUY_SIZE, ActionTypes.BUY, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxBuySize(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.accountMaxBuySizeStorage().active = _on;
        if (_on) {
            emit ApplicationHandlerActionActivated(ACCOUNT_MAX_BUY_SIZE, ActionTypes.BUY);
        } else {
            emit ApplicationHandlerActionDeactivated(ACCOUNT_MAX_BUY_SIZE, ActionTypes.BUY);
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

