// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ApplicationRuleProcessorDiamondLib as actionDiamond, ApplicationRuleDataStorage} from "./ApplicationRuleProcessorDiamondLib.sol";
import {AppRuleDataFacet} from "src/economic/ruleStorage/AppRuleDataFacet.sol";
import {IApplicationRules as Application} from "src/economic/ruleStorage/RuleDataInterfaces.sol";

/**
 * @title AccessLevel Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements AccessLevel Rule Checks on Tagged Accounts. AccessLevel rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract ApplicationAccessLevelProcessorFacet {
    error RuleDoesNotExist();
    error BalanceExceedsAccessLevelAllowedLimit();
    error NotAllowedForAccessLevel();

    /**
     * @dev Check if transaction passes Balance by AccessLevel rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param _accessLevel the Access Level of the account
     * @param _balance account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer total USD amount to be transferred with 18 decimals of precision
     */
    function checkBalanceByAccessLevelPasses(uint32 _ruleId, uint8 _accessLevel, uint256 _balance, uint256 _amountToTransfer) external view {
        AppRuleDataFacet data = AppRuleDataFacet(actionDiamond.applicationStorage().ruleDiamondAddress);
        /// Get the account's AccessLevel Level
        if (data.getTotalAccessLevelBalanceRules() != 0) {
            try data.getAccessLevelBalanceRule(_ruleId, _accessLevel) returns (uint48 max) {
                /// max has to be multiplied by 10 ** 18 to take decimals in token pricing into account
                if (_amountToTransfer + _balance > (uint256(max) * (10 ** 18))) revert BalanceExceedsAccessLevelAllowedLimit();
            } catch {
                revert RuleDoesNotExist();
            }
        }
    }

    /**
     * @dev Check if transaction passes AccessLevel 0 rule.This has no stored rule as there are no additional variables needed.
     * @param _accessLevel the Access Level of the account
     */
    function checkAccessLevel0Passes(uint8 _accessLevel) external pure {
        if (_accessLevel == 0) {
            revert NotAllowedForAccessLevel();
        }
    }
}
