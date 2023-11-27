// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RuleProcessorDiamondLib as actionDiamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {AppRuleDataFacet} from "./AppRuleDataFacet.sol";
import {IApplicationRules as ApplicationRuleStorage} from "./RuleDataInterfaces.sol";
import {IRuleProcessorErrors, IRiskErrors} from "../../interfaces/IErrors.sol";
import "./RuleProcessorCommonLib.sol";

/**
 * @title Risk Score Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Risk Score Rules. All risk rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract ApplicationRiskProcessorFacet is IRuleProcessorErrors, IRiskErrors {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint8; 
    /**
     * @dev Account balance by Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _toAddress Address of the recipient
     * @param _riskScore the Risk Score of the recepient account
     * @param _totalValuationTo recipient account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer total dollar amount to be transferred in USD with 18 decimals of precision
     * @notice _balanceLimits size must be equal to _riskLevel.
     * The positioning of the arrays is ascendant in terms of risk levels,
     * and descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      balances         resultant logic
     * -----------      --------         ---------------
     *                                   0-24  =   NO LIMIT 
     *    25              500            25-49 =   500
     *    50              250            50-74 =   250
     *    75              100            75-99 =   100
     */
    function checkAccBalanceByRisk(uint32 _ruleId, address _toAddress, uint8 _riskScore, uint128 _totalValuationTo, uint128 _amountToTransfer) external view {
        /// create the 'data' variable which is simply a connection to the rule diamond
        AppRuleDataFacet data = AppRuleDataFacet(actionDiamond.ruleDataStorage().rules);
        uint256 totalRules = data.getTotalAccountBalanceByRiskScoreRules();
        if (totalRules <= _ruleId) revert RuleDoesNotExist();
        /// retrieve the rule
        ApplicationRuleStorage.AccountBalanceToRiskRule memory rule = data.getAccountBalanceByRiskScore(_ruleId);
        uint256 ruleMaxSize;
        uint256 total = _totalValuationTo + _amountToTransfer;
        /// perform the rule check
        /// If recipient address being checked is zero address the rule passes (This allows for burning)
        if (_toAddress != address(0)) {
            /// If risk score is less than the first risk score of the rule, there is no limit.
            /// Skips the loop for gas efficiency on low risk scored users 
            if (_riskScore >= rule.riskLevel[0]) {
                ruleMaxSize = _riskScore.retrieveRiskScoreMaxSize(rule.riskLevel, rule.maxBalance);
                if (total > ruleMaxSize) revert BalanceExceedsRiskScoreLimit();
            }
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
     * @param _riskScore of the address (0 -> 100)
     * @return updated value for the _usdValueTransactedInPeriod. If _usdValueTransactedInPeriod are
     * inside the current period, then this value is accumulated. If not, it is reset to current amount.
     * @dev this check will cause a revert if the new value of _usdValueTransactedInPeriod in USD exceeds
     * the limit for the address risk profile.
     * @notice _balanceLimits size must be equal to _riskLevel 
     * The positioning of the arrays is ascendant in terms of risk levels, 
     * and descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      balances         resultant logic
     * -----------      --------         ---------------
     *                                   0-24  =   NO LIMIT 
     *    25              500            25-49 =   500
     *    50              250            50-74 =   250
     *    75              100            75-99 =   100
     */
    function checkMaxTxSizePerPeriodByRisk(uint32 ruleId, uint128 _usdValueTransactedInPeriod, uint128 amount, uint64 lastTxDate, uint8 _riskScore) external view returns (uint128) {
        /// we create the 'data' variable which is simply a connection to the rule diamond
        AppRuleDataFacet data = AppRuleDataFacet(actionDiamond.ruleDataStorage().rules);
        /// validation block
        uint256 totalRules = data.getTotalMaxTxSizePerPeriodRules();
        uint256 ruleMaxSize;
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();
        /// we retrieve the rule
        ApplicationRuleStorage.TxSizePerPeriodToRiskRule memory rule = data.getMaxTxSizePerPeriodRule(ruleId);
        /// resetting the "tradesWithinPeriod", unless we have been in current period for longer than the last update
        uint128 amountTransactedInPeriod = rule.startingTime.isWithinPeriod(rule.period, lastTxDate) ? 
        amount + _usdValueTransactedInPeriod: amount;
        /// If risk score is less than the first risk score of the rule, there is no limit.
        /// Skips the loop for gas efficiency on low risk scored users 
        if (_riskScore >= rule.riskLevel[0]) {
            ruleMaxSize = _riskScore.retrieveRiskScoreMaxSize(rule.riskLevel, rule.maxSize);
            if (amountTransactedInPeriod > ruleMaxSize) revert MaxTxSizePerPeriodReached(_riskScore, ruleMaxSize, rule.period);
            return amountTransactedInPeriod;
        } else {
            return amountTransactedInPeriod;
        }
    }
}
