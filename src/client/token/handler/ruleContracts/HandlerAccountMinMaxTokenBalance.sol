// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HandlerRuleContractsCommonImports.sol";
// import "src/protocol/economic/RuleAdministratorOnly.sol";


/**
 * @title Handler Account Min Max Token Balance 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

 struct AccountMinMaxTokenBalanceHandlerS{
    mapping(ActionTypes => Rule) accountMinMaxTokenBalance; 
 }

bytes32 constant ACCOUNT_MIN_MAX_TOKEN_BALANCE_POSITION = bytes32(uint256(keccak256("account-min-max-token-balance-position")) - 1);


contract HandlerAccountMinMaxTokenBalance is RuleAdministratorOnly, ITokenHandlerEvents{

    /// Rule Setters and Getters
    /**
     * @dev Set the accountMinMaxTokenBalanceRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setAccountMinMaxTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountMinMaxTokenBalance(_ruleId);
        for (uint i; i < _actions.length; ) {
            AccountMinMaxTokenBalanceHandlerS storage data = lib.accountMinMaxTokenBalanceStorage();
            data.accountMinMaxTokenBalance[_actions[i]].ruleId = _ruleId;
            data.accountMinMaxTokenBalance[_actions[i]].active = true;            
            emit ApplicationHandlerActionApplied(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions[i], _ruleId);
            unchecked {
                        ++i;
             }
        }            
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMinMaxTokenBalance(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ) {
            lib.accountMinMaxTokenBalanceStorage().accountMinMaxTokenBalance[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * Get the accountMinMaxTokenBalanceRuleId.
     * @param _action the action type
     * @return accountMinMaxTokenBalance rule id.
     */
    function getAccountMinMaxTokenBalanceId(ActionTypes _action) external view returns (uint32) {
        return lib.accountMinMaxTokenBalanceStorage().accountMinMaxTokenBalance[_action].ruleId;
    }

    /**
     * @dev Tells you if the AccountMinMaxTokenBalance is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isAccountMinMaxTokenBalanceActive(ActionTypes _action) external view returns (bool) {
        return lib.accountMinMaxTokenBalanceStorage().accountMinMaxTokenBalance[_action].active;
    }


}

