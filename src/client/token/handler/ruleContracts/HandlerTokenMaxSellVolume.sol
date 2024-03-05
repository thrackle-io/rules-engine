// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";


/**
 * @title Handler Token Max Sell Volume 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerTokenMaxSellVolume is RuleAdministratorOnly, ITokenHandlerEvents{

    /// Rule Setters and Getters
    /**
     * @dev Set the TokenMaxSellVolumeRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxSellVolumeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxSellVolume(_ruleId);
        TokenMaxSellVolumeS storage tokenMaxSellVolume = lib.tokenMaxSellVolumeStorage();
        tokenMaxSellVolume.id = _ruleId;
        tokenMaxSellVolume.active = true;
        emit ApplicationHandlerActionApplied(TOKEN_MAX_SELL_VOLUME, ActionTypes.SELL, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxSellVolume(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.tokenMaxSellVolumeStorage().active = _on;
        if (_on) {
            emit ApplicationHandlerActionActivated(TOKEN_MAX_SELL_VOLUME, ActionTypes.SELL);
        } else {
            emit ApplicationHandlerActionDeactivated(TOKEN_MAX_SELL_VOLUME, ActionTypes.SELL);
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

