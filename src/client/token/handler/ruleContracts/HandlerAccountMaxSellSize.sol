// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";


/**
 * @title Handler Account Max Sell Size 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerAccountMaxSellSize is RuleAdministratorOnly, ITokenHandlerEvents{

    /// Rule Setters and Getters
    /**
     * @dev Set the AccountMaxSellSizeRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxSellSizeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMaxSellSize(_ruleId);
        AccountMaxSellSizeS storage accountMaxSellSize = lib.accountMaxSellSizeStorage();
        accountMaxSellSize.id = _ruleId;
        accountMaxSellSize.active = true;
        emit AD1467_ApplicationHandlerActionApplied(ACCOUNT_MAX_SELL_SIZE, ActionTypes.SELL, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxSellSize(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.accountMaxSellSizeStorage().active = _on;
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(ACCOUNT_MAX_SELL_SIZE, ActionTypes.SELL);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(ACCOUNT_MAX_SELL_SIZE, ActionTypes.SELL);
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

