// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/client/token/handler/ruleContracts/HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Trading Volume
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerTokenMaxTradingVolume is RuleAdministratorOnly, ActionTypesArray, ITokenHandlerEvents, IAssetHandlerErrors {
    /// Rule Setters and Getters
    /**
     * @dev Retrieve the token max trading volume rule id
     * @param _action the action type(this left in to keep signatures the same for dependent apis)
     * @return tokenMaxTradingVolumeRuleId rule id
     */
    function getTokenMaxTradingVolumeId(ActionTypes _action) external view returns (uint32) {
        // since a single rule id is shared for all the actions, only return if active.
        if (!isTokenMaxTradingVolumeActive(_action)) return 0;
        else return lib.tokenMaxTradingVolumeStorage().ruleId;
    }

    /**
     * @dev Set the TokenMaxTradingVolume. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxTradingVolumeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxTradingVolume(_actions, _ruleId);
        for (uint i; i < _actions.length; ++i) {
            setTokenMaxTradingVolumeIdUpdate(_actions[i], _ruleId);
            emit AD1467_ApplicationHandlerActionApplied(TOKEN_MAX_TRADING_VOLUME, _actions[i], _ruleId);
        }
    }

    /**
     * @dev Set the setAccountMinMaxTokenBalanceRule suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions actions to have the rule applied to
     * @param _ruleId Rule Id corresponding to the actions
     */
    function setTokenMaxTradingVolumeIdFull(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if(_actions.length == 0) revert InputArraysSizesNotValid();
        clearTokenMaxTradingVolume(); 
        for (uint i; i < _actions.length; ) {
            setTokenMaxTradingVolumeIdUpdate(_actions[i], _ruleId);
            unchecked {
                ++i;
            }
        } 
        uint32[] memory _ruleIds = new uint32[](1);
        _ruleIds[0] = _ruleId;
        emit AD1467_ApplicationHandlerActionAppliedFull(TOKEN_MAX_TRADING_VOLUME, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMaxTradingVolume() internal {
        TokenMaxTradingVolumeS storage data = lib.tokenMaxTradingVolumeStorage();
        clearTokenMaxTradingVolumeAccumulators();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction; ++i) {
            delete data.tokenMaxTradingVolume[ActionTypes(i)];
        }
    }

     /**
     * @dev Clear the rule data accumulators
     */
    function clearTokenMaxTradingVolumeAccumulators() internal {
        TokenMaxTradingVolumeS storage data = lib.tokenMaxTradingVolumeStorage();
        delete data.ruleId;
        delete data.transferVolume;
        delete data.lastTransferTime;
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMaxTradingVolumeSingleAction(ActionTypes _action) internal {
        TokenMaxTradingVolumeS storage data = lib.tokenMaxTradingVolumeStorage();
        clearTokenMaxTradingVolumeAccumulators();
        delete data.ruleId;
        delete data.tokenMaxTradingVolume[_action];
    }

    /**
     * @dev Set the TokenMaxTradingVolume.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setTokenMaxTradingVolumeIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxTradingVolume(createActionTypesArray(_action), _ruleId);
        clearTokenMaxTradingVolumeSingleAction(_action);
        TokenMaxTradingVolumeS storage data = lib.tokenMaxTradingVolumeStorage();
        data.ruleId = _ruleId;
        data.tokenMaxTradingVolume[_action] = true;
    }

    /**
     * @dev Tells you if the token max trading volume rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMaxTradingVolume(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if(_on) clearTokenMaxTradingVolumeAccumulators();
        for (uint i; i < _actions.length; ++i) {
            lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[_actions[i]] = _on;
        }
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(TOKEN_MAX_TRADING_VOLUME, _actions, 0);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(TOKEN_MAX_TRADING_VOLUME, _actions, 0);
        }
    }

    /**
     * @dev Tells you if the token max trading volume rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMaxTradingVolumeActive(ActionTypes _action) public view returns (bool) {
        return lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[_action];
    }
}
