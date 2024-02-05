// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import {StorageLib as lib} from "../diamond/StorageLib.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import "../../../../protocol/economic/ruleProcessor/RuleCodeData.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";


/**
 * @title Handly Type Enum
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores the Handler Types for the protocol 
 */

 struct AccountApproveDenyOracleS{
    mapping(ActionTypes => Rule[]) accountAllowDenyOracle;
 }

bytes32 constant ACCOUNT_APPROVE_DENY_ORACLE_POSITION = bytes32(uint256(keccak256("account-approve-deny-oracle-position")) - 1);


contract HandlerAccountApproveDenyOracle is RuleAdministratorOnly, ITokenHandlerEvents{

    /// Rule Setters and Getters
    /**
     * @dev Set the accountApproveDenyOracleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setAccountApproveDenyOracleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateAccountApproveDenyOracle(_ruleId);
        for (uint i; i < _actions.length; ) {
            mapping(ActionTypes => Rule[]) storage accountAllowDenyOracle = lib.accountApproveDenyOracleStorage().accountAllowDenyOracle;
            if (accountAllowDenyOracle[_actions[i]].length >= MAX_ORACLE_RULES) {
                revert AccountApproveDenyOraclesPerAssetLimitReached();
            }

            Rule memory newOracleRule;
            newOracleRule.ruleId = _ruleId;
            newOracleRule.active = true;
            accountAllowDenyOracle[_actions[i]].push(newOracleRule);
            emit ApplicationHandlerActionApplied(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i], _ruleId);
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

    function activateAccountApproveDenyOracle(ActionTypes[] calldata _actions, bool _on, uint32 ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            mapping(ActionTypes => Rule[]) storage accountAllowDenyOracle = lib.accountApproveDenyOracleStorage().accountAllowDenyOracle;
            for (uint256 ruleIndex; ruleIndex < accountAllowDenyOracle[_actions[i]].length; ) {
                if (accountAllowDenyOracle[_actions[i]][ruleIndex].ruleId == ruleId) {
                    accountAllowDenyOracle[_actions[i]][ruleIndex].active = _on;

                    if (_on) {
                        emit ApplicationHandlerActionActivated(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i]);
                    } else {
                        emit ApplicationHandlerActionDeactivated(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i]);
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
        mapping(ActionTypes => Rule[]) storage accountAllowDenyOracle = lib.accountApproveDenyOracleStorage().accountAllowDenyOracle;
        uint32[] memory ruleIds = new uint32[](accountAllowDenyOracle[_action].length);
        for (uint256 ruleIndex; ruleIndex < accountAllowDenyOracle[_action].length; ) {
            ruleIds[ruleIndex] = accountAllowDenyOracle[_action][ruleIndex].ruleId;
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
        mapping(ActionTypes => Rule[]) storage accountAllowDenyOracle = lib.accountApproveDenyOracleStorage().accountAllowDenyOracle;
        for (uint256 ruleIndex; ruleIndex < accountAllowDenyOracle[_action].length; ) {
            if (accountAllowDenyOracle[_action][ruleIndex].ruleId == ruleId) {
                return accountAllowDenyOracle[_action][ruleIndex].active;
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
    function removeAccountApproveDenyOracle(ActionTypes[] calldata _actions, uint32 ruleId) external ruleAdministratorOnly(appManagerAddress) {
        mapping(ActionTypes => Rule[]) storage accountAllowDenyOracle = lib.accountApproveDenyOracleStorage().accountAllowDenyOracle;
        for (uint i; i < _actions.length; ) {
            Rule memory lastId = accountAllowDenyOracle[_actions[i]][accountAllowDenyOracle[_actions[i]].length -1];
            if(ruleId != lastId.ruleId){
                uint index = 0;
                for (uint256 ruleIndex; ruleIndex < accountAllowDenyOracle[_actions[i]].length; ) {
                    if (accountAllowDenyOracle[_actions[i]][ruleIndex].ruleId == ruleId) {
                        index = ruleIndex; 
                        break;
                    }
                    unchecked {
                        ++ruleIndex;
                    }
                }
                accountAllowDenyOracle[_actions[i]][index] = lastId;
            }

            accountAllowDenyOracle[_actions[i]].pop();
            unchecked {
                        ++i;
            }
        }
    }

}

