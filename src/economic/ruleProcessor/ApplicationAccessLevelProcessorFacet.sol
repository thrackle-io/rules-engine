// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RuleProcessorDiamondLib as actionDiamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {AppRuleDataFacet} from "../ruleStorage/AppRuleDataFacet.sol";
import {IApplicationRules as Application} from "../ruleStorage/RuleDataInterfaces.sol";
import {IRuleProcessorErrors, IAccessLevelErrors} from "../../interfaces/IErrors.sol";

/**
 * @title AccessLevel Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements AccessLevel Rule Checks. AccessLevel rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract ApplicationAccessLevelProcessorFacet is IRuleProcessorErrors, IAccessLevelErrors{
   

    /**
     * @dev Check if transaction passes Balance by AccessLevel rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param _accessLevel the Access Level of the account
     * @param _balance account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer total USD amount to be transferred with 18 decimals of precision
     */
    function checkAccBalanceByAccessLevel(uint32 _ruleId, uint8 _accessLevel, uint128 _balance, uint128 _amountToTransfer) external view {
        AppRuleDataFacet data = AppRuleDataFacet(actionDiamond.ruleDataStorage().rules);
        /// Get the account's AccessLevel
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
     * @dev Check if transaction passes Withdrawal by AccessLevel rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param _accessLevel the Access Level of the account
     * @param _usdWithdrawalTotal account's total amount withdrawn in USD with 18 decimals of precision
     * @param _usdAmountTransferring total USD amount to be transferred with 18 decimals of precision
     */
    function checkwithdrawalLimitsByAccessLevel(uint32 _ruleId, uint8 _accessLevel, uint128 _usdWithdrawalTotal, uint128 _usdAmountTransferring) external view returns (uint128) {
        AppRuleDataFacet data = AppRuleDataFacet(actionDiamond.ruleDataStorage().rules);
        if (data.getTotalAccessLevelWithdrawalRules() < _ruleId) revert RuleDoesNotExist();
        uint128 usdWithdrawnTotal = _usdWithdrawalTotal;
        uint48 max = data.getAccessLevelWithdrawalRule(_ruleId, _accessLevel);
        /// max has to be multiplied by 10 ** 18 to take decimals in token pricing into account
        if (_usdAmountTransferring + usdWithdrawnTotal > (uint256(max) * (10 ** 18))) revert WithdrawalExceedsAccessLevelAllowedLimit();
        if (_usdAmountTransferring + usdWithdrawnTotal <= (uint256(max) * (10 ** 18))) {
            usdWithdrawnTotal += _usdAmountTransferring;
        }
        return usdWithdrawnTotal;
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
