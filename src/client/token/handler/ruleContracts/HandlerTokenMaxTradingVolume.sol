// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Trading Volume 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerTokenMaxTradingVolume is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors{

    /// Rule Setters and Getters
    /**
     * @dev Retrieve the token max trading volume rule id
     * @param _action the action type
     * @return tokenMaxTradingVolumeRuleId rule id
     */
    function getTokenMaxTradingVolumeId(ActionTypes _action) external view returns (uint32) {
        return lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[_action].ruleId;
    }

    /**
     * @dev Set the tokenMaxTradingVolumeRuleId. Restricted to rule admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxTradingVolumeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        TokenMaxTradingVolumeS storage data = lib.tokenMaxTradingVolumeStorage();
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxTradingVolume(_ruleId);
        for (uint i; i < _actions.length; ) {
            data.tokenMaxTradingVolume[_actions[i]].ruleId = _ruleId;
            data.tokenMaxTradingVolume[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(TOKEN_MAX_TRADING_VOLUME, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the token max trading volume rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMaxTradingVolume(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        for (uint i; i < _actions.length; ) {
            lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MAX_TRADING_VOLUME, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MAX_TRADING_VOLUME, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the token max trading volume rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMaxTradingVolumeActive(ActionTypes _action) external view returns (bool) {
        return lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[_action].active;
    }

}

