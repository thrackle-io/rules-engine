// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Rule} from "../DataStructures.sol";
import {ActionTypes} from "../../../../protocol/economic/ruleProcessor/ActionEnum.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import {ACCOUNT_MIN_MAX_TOKEN_BALANCE} from "../../../../protocol/economic/ruleProcessor/RuleCodeData.sol";
import {StorageLib as lib} from "../facets/StorageLib.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";


/**
 * @title Handly Type Enum
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores the Handler Types for the protocol 
 */

 struct AccountMinMaxTokenBalanceHandlerS{
    mapping(ActionTypes => Rule) accountMinMaxTokenBalance; 
 }

bytes32 constant ACCOUNT_MIN_MAX_TOKEN_BALANCE_POSITION = bytes32(uint256(keccak256("account-min-max-token-balance-position")) - 1);


contract AccountMinMaxTokenBalanceGetterSetter is RuleAdministratorOnly, ITokenHandlerEvents{

    /// Rule Setters and Getters
    /**
     * @dev Set the accountMinMaxTokenBalanceRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setAccountMinMaxTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManagerAddress) {
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
    function activateAccountMinMaxTokenBalance(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManagerAddress) {
        AccountMinMaxTokenBalanceHandlerS storage data = lib.accountMinMaxTokenBalanceStorage();
        for (uint i; i < _actions.length; ) {
            data.accountMinMaxTokenBalance[_actions[i]].active = _on;
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
        AccountMinMaxTokenBalanceHandlerS storage data = lib.accountMinMaxTokenBalanceStorage();
        return data.accountMinMaxTokenBalance[_action].ruleId;
    }

    /**
     * @dev Tells you if the AccountMinMaxTokenBalance is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isAccountMinMaxTokenBalanceActive(ActionTypes _action) external view returns (bool) {
        AccountMinMaxTokenBalanceHandlerS storage data = lib.accountMinMaxTokenBalanceStorage();
        return data.accountMinMaxTokenBalance[_action].active;
    }


}

