// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";


uint8 constant MAX_ORACLE_RULES = 10;

/**
 * @title Handler Account Approve Deny Oracle 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerAccountApproveDenyOracle is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors{

    /// Rule Setters and Getters
    /**
     * @dev Set the accountApproveDenyOracleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setAccountApproveDenyOracleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountApproveDenyOracle(_ruleId);
        for (uint i; i < _actions.length; ) {
            mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;
            if (accountApproveDenyOracle[_actions[i]].length >= MAX_ORACLE_RULES) {
                revert AccountApproveDenyOraclesPerAssetLimitReached();
            }

            Rule memory newOracleRule = Rule(_ruleId, true);
            accountApproveDenyOracle[_actions[i]].push(newOracleRule);
            emit AD1467_ApplicationHandlerActionApplied(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     * @param ruleId the id of the rule to activate/deactivate
     */

    function activateAccountApproveDenyOracle(ActionTypes[] calldata _actions, bool _on, uint32 ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ) {
            mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;
            for (uint256 ruleIndex; ruleIndex < accountApproveDenyOracle[_actions[i]].length; ) {
                if (accountApproveDenyOracle[_actions[i]][ruleIndex].ruleId == ruleId) {
                    accountApproveDenyOracle[_actions[i]][ruleIndex].active = _on;

                    if (_on) {
                        emit AD1467_ApplicationHandlerActionActivated(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i]);
                    } else {
                        emit AD1467_ApplicationHandlerActionDeactivated(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i]);
                    }
                }
                unchecked {
                    ++ruleIndex;
                }
            }
            unchecked {
                    ++i;
            }
        }
    }

    /**
     * @dev Retrieve the account approve deny oracle rule id
     * @param _action the action type
     * @return oracleRuleId
     */
    function getAccountApproveDenyOracleIds(ActionTypes _action) external view returns (uint32[] memory ) {
        mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;
        uint32[] memory ruleIds = new uint32[](accountApproveDenyOracle[_action].length);
        for (uint256 ruleIndex; ruleIndex < accountApproveDenyOracle[_action].length; ) {
            ruleIds[ruleIndex] = accountApproveDenyOracle[_action][ruleIndex].ruleId;
            unchecked {
                ++ruleIndex;
            }
        }
        return ruleIds;
    }

    /**
     * @dev Tells you if the Accont Approve Deny Oracle Rule is active or not.
     * @param _action the action type
     * @param ruleId the id of the rule to check
     * @return boolean representing if the rule is active
     */
    function isAccountAllowDenyOracleActive(ActionTypes _action, uint32 ruleId) external view returns (bool) {
        mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;
        for (uint256 ruleIndex; ruleIndex < accountApproveDenyOracle[_action].length; ) {
            if (accountApproveDenyOracle[_action][ruleIndex].ruleId == ruleId) {
                return accountApproveDenyOracle[_action][ruleIndex].active;
            }
            unchecked {
                ++ruleIndex;
            }
        }
        return false;
    }

    /**
     * @dev Removes an account approve deny oracle rule from the list.
     * @param _actions the action types
     * @param ruleId the id of the rule to remove
     */
    function removeAccountApproveDenyOracle(ActionTypes[] calldata _actions, uint32 ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;
        for (uint i; i < _actions.length; ) {
            Rule memory lastId = accountApproveDenyOracle[_actions[i]][accountApproveDenyOracle[_actions[i]].length -1];
            if(ruleId != lastId.ruleId){
                uint index = 0;
                for (uint256 ruleIndex; ruleIndex < accountApproveDenyOracle[_actions[i]].length; ) {
                    if (accountApproveDenyOracle[_actions[i]][ruleIndex].ruleId == ruleId) {
                        index = ruleIndex; 
                        break;
                    }
                    unchecked {
                        ++ruleIndex;
                    }
                }
                accountApproveDenyOracle[_actions[i]][index] = lastId;
            }

            accountApproveDenyOracle[_actions[i]].pop();
            unchecked {
                        ++i;
            }
        }
    }

}

