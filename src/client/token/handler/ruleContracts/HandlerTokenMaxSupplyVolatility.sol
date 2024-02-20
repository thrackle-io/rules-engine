// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Supply Volatility 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */


contract HandlerTokenMaxSupplyVolatility is RuleAdministratorOnly, ITokenHandlerEvents, IAssetHandlerErrors{

    /// Rule Setters and Getters
    /**
     * @dev Retrieve the token max supply volatility rule id
     * @param _action the action type
     * @return totalTokenMaxSupplyVolatilityId rule id
     */
    function getTokenMaxSupplyVolatilityId(ActionTypes _action) external view returns (uint32) {
        return lib.tokenMaxSupplyVolatilityStorage().tokenMaxSupplyVolatility[_action].ruleId;
    }

    /**
     * @dev Set the tokenMaxSupplyVolatilityRuleId. Restricted to rule admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxSupplyVolatilityId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        TokenMaxSupplyVolatilityS storage data = lib.tokenMaxSupplyVolatilityStorage();
        for (uint i; i < _actions.length; ) {
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxSupplyVolatility(_ruleId);
            data.tokenMaxSupplyVolatility[_actions[i]].ruleId = _ruleId;
            data.tokenMaxSupplyVolatility[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(TOKEN_MAX_SUPPLY_VOLATILITY, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the Token Max Supply Volatility rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMaxSupplyVolatility(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        TokenMaxSupplyVolatilityS storage data = lib.tokenMaxSupplyVolatilityStorage();
        for (uint i; i < _actions.length; ) {
            data.tokenMaxSupplyVolatility[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MAX_SUPPLY_VOLATILITY, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MAX_SUPPLY_VOLATILITY, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the Token Max Supply Volatility is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMaxSupplyVolatilityActive(ActionTypes _action) external view returns (bool) {
        return lib.tokenMaxSupplyVolatilityStorage().tokenMaxSupplyVolatility[_action].active;
    }


}

