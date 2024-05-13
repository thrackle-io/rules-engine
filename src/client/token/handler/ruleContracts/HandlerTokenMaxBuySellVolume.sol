// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Buy Sell Volume
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerTokenMaxBuySellVolume is RuleAdministratorOnly, ActionTypesArray, ITokenHandlerEvents, IAssetHandlerErrors {
    /// Rule Setters and Getters
    /**
     * @dev Retrieve the Account Max Buy Sell Size Rule Id
     * @param _actions the action types
     * @return accountMaxBuySellSizeId
     */
    function getTokenMaxBuySellVolumeId(ActionTypes _actions) external view returns (uint32) {
        return lib.tokenMaxBuySellVolumeStorage().tokenMaxBuySellVolume[_actions].ruleId;
    }

    /**
     * @dev Set the TokenMaxBuySellVolume. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxBuySellVolumeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxBuySellVolume(_actions, _ruleId);
        clearTokenMaxBuySellVolumeAccumulators();
        for (uint i; i < _actions.length; ++i) {
            setTokenMaxBuySellVolumeIdUpdate(_actions[i], _ruleId);
            emit AD1467_ApplicationHandlerActionApplied(TOKEN_MAX_BUY_SELL_VOLUME, _actions[i], _ruleId);
        }
    }

    /**
     * @dev Set the TokenMaxBuySellVolume suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setTokenMaxBuySellVolumeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length == 0) revert InputArraysSizesNotValid();
        if (_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearTokenMaxBuySellVolume();
        for (uint i; i < _actions.length; ++i) {
            setTokenMaxBuySellVolumeIdUpdate(_actions[i], _ruleIds[i]);
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(TOKEN_MAX_BUY_SELL_VOLUME, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMaxBuySellVolume() internal {
        TokenMaxBuySellVolumeS storage data = lib.tokenMaxBuySellVolumeStorage();
        clearTokenMaxBuySellVolumeAccumulators();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction;) {
            delete data.tokenMaxBuySellVolume[ActionTypes(i)];
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Clear the rule data accumulators
     */
    function clearTokenMaxBuySellVolumeAccumulators() internal {
        TokenMaxBuySellVolumeS storage data = lib.tokenMaxBuySellVolumeStorage();
        delete data.boughtInPeriod;
        delete data.lastPurchaseTime;
        delete data.salesInPeriod;
        delete data.lastSellTime;
    }

    /**
     * @dev Set the TokenMaxBuySellVolume.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setTokenMaxBuySellVolumeIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        if (!(_action == ActionTypes.SELL || _action == ActionTypes.BUY)) revert InvalidAction();
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxBuySellVolume(createActionTypesArray(_action), _ruleId);
        TokenMaxBuySellVolumeS storage data = lib.tokenMaxBuySellVolumeStorage();
        data.tokenMaxBuySellVolume[_action].ruleId = _ruleId;
        data.tokenMaxBuySellVolume[_action].active = true;
        if (_action == ActionTypes.BUY) {
            delete data.boughtInPeriod;
            delete data.lastPurchaseTime;
        } else if (_action == ActionTypes.SELL) {
            delete data.salesInPeriod;
            delete data.lastSellTime;
        }
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action type to set the rule
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxBuySellVolume(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if(_on) clearTokenMaxBuySellVolumeAccumulators();
        for (uint i; i < _actions.length; ++i) {
            if (!(_actions[i] == ActionTypes.SELL || _actions[i] == ActionTypes.BUY)) revert InvalidAction();
            lib.tokenMaxBuySellVolumeStorage().tokenMaxBuySellVolume[_actions[i]].active = _on;
        }
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(TOKEN_MAX_BUY_SELL_VOLUME, _actions);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(TOKEN_MAX_BUY_SELL_VOLUME, _actions);
        }
    }

    /**
     * @dev Tells you if the Account Max Buy Sell Size Rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMaxBuySellVolumeActive(ActionTypes _action) external view returns (bool) {
        return lib.tokenMaxBuySellVolumeStorage().tokenMaxBuySellVolume[_action].active;
    }
}
