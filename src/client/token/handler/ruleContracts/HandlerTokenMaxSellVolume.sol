// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";


/**
 * @title Handler Token Max Sell Volume 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerTokenMaxSellVolume is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors{

    /// Rule Setters and Getters

    /**
     * @dev Set the AccountMaxSellSizeRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxSellVolumeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        setTokenMaxSellVolumeIdUpdate(ActionTypes.SELL, _ruleId);
        emit AD1467_ApplicationHandlerActionApplied(TOKEN_MAX_SELL_VOLUME, ActionTypes.SELL, _ruleId);
    }

    /**
     * @dev Set the TokenMaxSellVolume suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setTokenMaxSellVolumeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if(_actions.length == 0) revert InputArraysSizesNotValid();
        if(_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearTokenMaxSellVolume(); 
        for (uint i; i < _actions.length; ) {
            setTokenMaxSellVolumeIdUpdate(_actions[i], _ruleIds[i]);
            unchecked {
                ++i;
            }
        } 
         emit AD1467_ApplicationHandlerActionAppliedFull(TOKEN_MAX_SELL_VOLUME, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMaxSellVolume() internal {
        TokenMaxSellVolumeS storage data = lib.tokenMaxSellVolumeStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction; ) {
            delete data.id;
            delete data.active;
            unchecked {
                ++i;
            }
        }
    }
    /**
     * @dev Set the TokenMaxSellVolume. 
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxSellVolumeIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        if (_action != ActionTypes.SELL) revert InvalidAction();
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxSellVolume(_ruleId);
        TokenMaxSellVolumeS storage tokenMaxSellVolume = lib.tokenMaxSellVolumeStorage();
        tokenMaxSellVolume.id = _ruleId;
        tokenMaxSellVolume.active = true;
    }
    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxSellVolume(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.tokenMaxSellVolumeStorage().active = _on;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.SELL;
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(TOKEN_MAX_SELL_VOLUME, actionsArray);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(TOKEN_MAX_SELL_VOLUME, actionsArray);
        }
    }

    /**
     * @dev Retrieve the Account Max Sell Size Rule Id
     * @return accountMaxSellSizeId
     */
    function getTokenMaxSellVolumeId() external view returns (uint32) {
        return lib.tokenMaxSellVolumeStorage().id;
    }

    /**
     * @dev Tells you if the Account Max Sell Size Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTokenMaxSellVolumeActive() external view returns (bool) {
        return lib.tokenMaxSellVolumeStorage().active;
    }

}

