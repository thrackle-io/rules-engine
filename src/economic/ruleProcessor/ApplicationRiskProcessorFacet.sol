// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RuleProcessorDiamondLib as actionDiamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {AppRuleDataFacet} from "src/economic/ruleStorage/AppRuleDataFacet.sol";
import {IApplicationRules as ApplicationRuleStorage} from "src/economic/ruleStorage/RuleDataInterfaces.sol";
import {IRuleProcessorErrors, IRiskErrors} from "../../interfaces/IErrors.sol";

/**
 * @title Risk Score Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Risk Score Rules. All risk rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract ApplicationRiskProcessorFacet is IRuleProcessorErrors, IRiskErrors {
    

    /**
     * @dev Account balance by Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _riskScore the Risk Score of the recepient account
     * @param _totalValuationTo recipient account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer total dollar amount to be transferred in USD with 18 decimals of precision
     * @notice _balanceLimits size must be equal to _riskLevel + 1 since the _balanceLimits must
     * specify the maximum tx size for anything below the first level and between the highest risk score and 100. This also
     * means that the positioning of the arrays is ascendant in terms of risk levels, and
     * descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      balances         resultant logic
     * -----------      --------         ---------------
     *    25             1000            0-24  =  1000
     *    50              500            25-49 =   500
     *    75              250            50-74 =   250
     *                    100            75-99 =   100
     */
    function checkAccBalanceByRisk(uint32 _ruleId, uint8 _riskScore, uint128 _totalValuationTo, uint128 _amountToTransfer) external view {
        /// create the 'data' variable which is simply a connection to the rule diamond
        AppRuleDataFacet data = AppRuleDataFacet(actionDiamond.ruleDataStorage().rules);
        uint256 totalRules = data.getTotalAccountBalanceByRiskScoreRules();
        if ((totalRules > 0 && totalRules <= _ruleId) || totalRules == 0) revert RuleDoesNotExist();
        /// retrieve the rule
        ApplicationRuleStorage.AccountBalanceToRiskRule memory rule = data.getAccountBalanceByRiskScore(_ruleId);
        uint total = _totalValuationTo + _amountToTransfer;
        /// perform the rule check
        for (uint256 i; i < rule.riskLevel.length; ) {
            ///If risk score is within the rule riskLevel array, find the maxBalance for that risk Score
            if (_riskScore < rule.riskLevel[i]) {
                /// maxBalance must be multiplied by 10 ** 18 to account for decimals in token pricing in USD
                if (total > uint(rule.maxBalance[i]) * (10 ** 18)) {
                    revert BalanceExceedsRiskScoreLimit();
                } else {
                    ///Jump out of loop once risk score is matched to array index
                    break;
                }
            }
            unchecked {
                ++i;
            }
        }
        ///Check if Risk Score is higher than highest riskLevel for rule
        if (_riskScore >= rule.riskLevel[rule.riskLevel.length - 1]) {
            if (total > uint256(rule.maxBalance[rule.maxBalance.length - 1]) * (10 ** 18)) revert BalanceExceedsRiskScoreLimit();
        }
    }

    /**
     * @dev rule that checks if the tx exceeds the limit size in USD for a specific risk profile
     * within a specified period of time.
     * @notice that these ranges are set by ranges.
     * @param ruleId to check against.
     * @param _usdValueTransactedInPeriod the cumulative amount of tokens recorded in the last period.
     * @param amount in USD of the current transaction with 18 decimals of precision.
     * @param lastTxDate timestamp of the last transfer of this token by this address.
     * @param riskScore of the address (0 -> 100)
     * @return updated value for the _usdValueTransactedInPeriod. If _usdValueTransactedInPeriod are
     * inside the current period, then this value is accumulated. If not, it is reset to current amount.
     * @dev this check will cause a revert if the new value of _usdValueTransactedInPeriod in USD exceeds
     * the limit for the address risk profile.
     * @notice _balanceLimits size must be equal to _riskLevel + 1 since the _balanceLimits must
     * specify the maximum tx size for anything below the first level and between the highest risk score and 100. This also
     * means that the positioning of the arrays is ascendant in terms of risk levels, and
     * descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      balances         resultant logic
     * -----------      --------         ---------------
     *    25             1000            0-24  =  1000
     *    50              500            25-49 =   500
     *    75              250            50-74 =   250
     *                    100            75-99 =   100
     */
    function checkMaxTxSizePerPeriodByRisk(uint32 ruleId, uint128 _usdValueTransactedInPeriod, uint128 amount, uint64 lastTxDate, uint8 riskScore) external view returns (uint128) {
        /// we create the 'data' variable which is simply a connection to the rule diamond
        AppRuleDataFacet data = AppRuleDataFacet(actionDiamond.ruleDataStorage().rules);
        /// validation block
        uint256 totalRules = data.getTotalMaxTxSizePerPeriodRules();
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();

        /// we retrieve the rule
        ApplicationRuleStorage.TxSizePerPeriodToRiskRule memory rule = data.getMaxTxSizePerPeriodRule(ruleId);
        /// reseting the "tradesWithinPeriod", unless...
        uint128 amountTransactedInPeriod = amount;
        /// if (we have been in current period for longer than the last update)...
        if (((block.timestamp - rule.startingTime) % (uint256(rule.period) * 1 hours)) >= (block.timestamp - lastTxDate)) {
            /// This means that the last trades "tradesWithinPeriod" were inside current period,
            /// and we need to acumulate this trade to the those ones
            amountTransactedInPeriod = amount + _usdValueTransactedInPeriod;
        }
        for (uint256 i; i < rule.riskLevel.length; ) {
            if (riskScore < rule.riskLevel[i]) {
                /// we found our range. Now we check...
                if (amountTransactedInPeriod > uint256(rule.maxSize[i]) * (10 ** 18)) revert MaxTxSizePerPeriodReached(riskScore, rule.maxSize[i], rule.period);
                /// since we found our range, and it didn't revert, we can leave and update
                /// tradesWithinPeriod value
                return amountTransactedInPeriod;
            }
            unchecked {
                ++i;
            }
        }
        /// but if none of the risk levels were greater than the risk profile of the address,
        /// then we check against the last value of the maxSize array.
        if (amountTransactedInPeriod > (uint256(rule.maxSize[rule.maxSize.length - 1]) * (10 ** 18))) revert MaxTxSizePerPeriodReached(riskScore, rule.maxSize[rule.maxSize.length - 1], rule.period);
        return amountTransactedInPeriod;
    }
}
