// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HandlerRuleContractsCommonImports.sol";


/**
 * @title Handler Account Max Buy Size 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerTokenMaxBuyVolume is RuleAdministratorOnly, ITokenHandlerEvents{

    /// Rule Setters and Getters
    /**
     * @dev Set the TokenMaxBuyVolumeRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxBuyVolumeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxBuyVolume(_ruleId);
        TokenMaxBuyVolumeS storage tokenMaxBuyVolume = lib.tokenMaxBuyVolumeStorage();
        tokenMaxBuyVolume.id = _ruleId;
        tokenMaxBuyVolume.active = true;
        emit ApplicationHandlerActionApplied(TOKEN_MAX_BUY_VOLUME, ActionTypes.BUY, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxBuyVolume(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.tokenMaxBuyVolumeStorage().active = _on;
        if (_on) {
            emit ApplicationHandlerActionActivated(TOKEN_MAX_BUY_VOLUME, ActionTypes.BUY);
        } else {
            emit ApplicationHandlerActionDeactivated(TOKEN_MAX_BUY_VOLUME, ActionTypes.BUY);
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

