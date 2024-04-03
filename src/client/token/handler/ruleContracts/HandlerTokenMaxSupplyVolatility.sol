// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Handler Token Max Supply Volatility
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for the rule in the handler. Meant to be inherited by a handler
 * facet to easily support the rule.
 */
contract HandlerTokenMaxSupplyVolatility is RuleAdministratorOnly, ActionTypesArray, ITokenHandlerEvents, IAssetHandlerErrors {
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
     * @dev Set the TokenMaxSupplyVolatility. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxSupplyVolatilityId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxSupplyVolatility(_actions, _ruleId);
        for (uint i; i < _actions.length; ++i) {
            setTokenMaxSupplyVolatilityIdUpdate(_actions[i], _ruleId);
            emit AD1467_ApplicationHandlerActionApplied(TOKEN_MAX_SUPPLY_VOLATILITY, _actions[i], _ruleId);
        }
    }

    /**
     * @dev Set the setAccountMinMaxTokenBalanceRule suite. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions actions to have the rule applied to
     * @param _ruleIds Rule Id corresponding to the actions
     */
    function setTokenMaxSupplyVolatilityIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_actions.length == 0) revert InputArraysSizesNotValid();
        if (_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
        clearTokenMaxSupplyVolatility();
        for (uint i; i < _actions.length; ++i) {
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxSupplyVolatility(createActionTypesArray(_actions[i]), _ruleIds[i]);
            setTokenMaxSupplyVolatilityIdUpdate(_actions[i], _ruleIds[i]);
        }
        emit AD1467_ApplicationHandlerActionAppliedFull(TOKEN_MAX_SUPPLY_VOLATILITY, _actions, _ruleIds);
    }

    /**
     * @dev Clear the rule data structure
     */
    function clearTokenMaxSupplyVolatility() internal {
        TokenMaxSupplyVolatilityS storage data = lib.tokenMaxSupplyVolatilityStorage();
        for (uint i; i <= lib.handlerBaseStorage().lastPossibleAction; ++i) {
            delete data.tokenMaxSupplyVolatility[ActionTypes(i)];
        }
    }

    /**
     * @dev Set the TokenMaxSupplyVolatility.
     * @notice that setting a rule will automatically activate it.
     * @param _action the action type to set the rule
     * @param _ruleId Rule Id to set
     */
    // slither-disable-next-line calls-loop
    function setTokenMaxSupplyVolatilityIdUpdate(ActionTypes _action, uint32 _ruleId) internal {
        IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).validateTokenMaxSupplyVolatility(createActionTypesArray(_action), _ruleId);
        TokenMaxSupplyVolatilityS storage data = lib.tokenMaxSupplyVolatilityStorage();
        data.tokenMaxSupplyVolatility[_action].ruleId = _ruleId;
        data.tokenMaxSupplyVolatility[_action].active = true;
    }

    /**
     * @dev Tells you if the Token Max Supply Volatility rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMaxSupplyVolatility(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        TokenMaxSupplyVolatilityS storage data = lib.tokenMaxSupplyVolatilityStorage();
        for (uint i; i < _actions.length; ++i) {
            data.tokenMaxSupplyVolatility[_actions[i]].active = _on;
        }
        if (_on) {
            emit AD1467_ApplicationHandlerActionActivated(TOKEN_MAX_SUPPLY_VOLATILITY, _actions);
        } else {
            emit AD1467_ApplicationHandlerActionDeactivated(TOKEN_MAX_SUPPLY_VOLATILITY, _actions);
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
