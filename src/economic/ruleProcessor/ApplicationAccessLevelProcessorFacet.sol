// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RuleProcessorDiamondLib as processorDiamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {AppRuleDataFacet} from "./AppRuleDataFacet.sol";
import {IApplicationRules as Application} from "./RuleDataInterfaces.sol";
import {IRuleProcessorErrors, IAccessLevelErrors} from "../../interfaces/IErrors.sol";

/**
 * @title AccessLevel Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements AccessLevel Rule Checks. AccessLevel rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract ApplicationAccessLevelProcessorFacet is IRuleProcessorErrors, IAccessLevelErrors {
    /**
     * @dev Check if transaction passes Balance by AccessLevel rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param _accessLevel the Access Level of the account
     * @param _balance account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer total USD amount to be transferred with 18 decimals of precision
     */
    function checkAccBalanceByAccessLevel(uint32 _ruleId, uint8 _accessLevel, uint128 _balance, uint128 _amountToTransfer) external view {
        AppRuleDataFacet data = AppRuleDataFacet(processorDiamond.ruleDataStorage().rules);
        /// Get the account's AccessLevel
        if (data.getTotalAccessLevelBalanceRules() != 0) {
            uint48 max = data.getAccessLevelBalanceRule(_ruleId, _accessLevel);
            /// max has to be multiplied by 10 ** 18 to take decimals in token pricing into account
            if (_amountToTransfer + _balance > (uint256(max) * (10 ** 18))) revert BalanceExceedsAccessLevelAllowedLimit();
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
        AppRuleDataFacet data = AppRuleDataFacet(processorDiamond.ruleDataStorage().rules);
        uint48 max = data.getAccessLevelWithdrawalRule(_ruleId, _accessLevel);
        /// max has to be multiplied by 10 ** 18 to take decimals in token pricing into account
       if (_usdAmountTransferring + _usdWithdrawalTotal > (uint256(max) * (10 ** 18))) revert WithdrawalExceedsAccessLevelAllowedLimit();
        else _usdWithdrawalTotal += _usdAmountTransferring;
        return _usdWithdrawalTotal;
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
