// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Buy Volume
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */

contract HandlerTokenMaxBuyVolume is ActionTypesArray, RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors {
    /// Rule Setters and Getters
    /**
     * @dev Set the TokenMaxBuyVolume. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxBuyVolumeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxBuyVolume(createActionTypesArray(ActionTypes.BUY), _ruleId);
        /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
        setTokenMaxBuyVolumeIdUpdate(ActionTypes.BUY, _ruleId);
        emit AD1467_ApplicationHandlerActionApplied(TOKEN_MAX_BUY_VOLUME, ActionTypes.BUY, _ruleId);
    }

    /**
     * @dev Set the TokenMaxBuyVolume suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setTokenMaxBuyVolumeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length == 0) revert InputArraysSizesNotValid();
        if (_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearTokenMaxBuyVolume();
        for (uint i; i < _actions.length; ) {
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxBuyVolume(createActionTypesArray(_actions[i]), _ruleIds[i]);
            setTokenMaxBuyVolumeIdUpdate(_actions[i], _ruleIds[i]);
            unchecked {
                ++i;
            }
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(TOKEN_MAX_BUY_VOLUME, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMaxBuyVolume() internal {
        TokenMaxBuyVolumeS storage data = lib.tokenMaxBuyVolumeStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction; ) {
            delete data.id;
            delete data.active;
            delete data.boughtInPeriod;
            delete data.lastPurchaseTime;
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Set the TokenMaxBuyVolume.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setTokenMaxBuyVolumeIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        if (_action != ActionTypes.BUY) revert InvalidAction();
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxBuyVolume(createActionTypesArray(_action), _ruleId);
        TokenMaxBuyVolumeS storage data = lib.tokenMaxBuyVolumeStorage();
        data.id = _ruleId;
        data.active = true;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxBuyVolume(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.tokenMaxBuyVolumeStorage().active = _on;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.BUY;
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(TOKEN_MAX_BUY_VOLUME, actionsArray);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(TOKEN_MAX_BUY_VOLUME, actionsArray);
        }
    }

    /**
     * @dev Retrieve the Account Max Buy Size Rule Id
     * @return accountMaxBuySizeId
     */
    function getTokenMaxBuyVolumeId() external view returns (uint32) {
        return lib.tokenMaxBuyVolumeStorage().id;
    }

    /**
     * @dev Tells you if the Account Max Buy Size Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTokenMaxBuyVolumeActive() external view returns (bool) {
        return lib.tokenMaxBuyVolumeStorage().active;
    }
}
