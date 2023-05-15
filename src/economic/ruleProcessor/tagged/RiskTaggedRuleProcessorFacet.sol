// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {TaggedRuleProcessorDiamondLib as TaggedRulesDiamondLib, RuleDataStorage} from "./TaggedRuleProcessorDiamondLib.sol";
import {TaggedRuleDataFacet} from "../../ruleStorage/TaggedRuleDataFacet.sol";
import {ITaggedRules as TaggedRules} from "../../ruleStorage/RuleDataInterfaces.sol";

/**
 * @title Risk Rules Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements Risk Rules on Tagged Accounts. All risk rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract RiskTaggedRuleProcessorFacet {
    error RuleDoesNotExist();
    error MaxTxSizePerPeriodReached(uint8 riskScore, uint256 maxTxSize, uint8 hoursOfPeriod);
    error TransactionExceedsRiskScoreLimit();
    error BalanceExceedsRiskScoreLimit();

    /**
     * @dev Transaction Limit for Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _riskScore the Risk Score of the account
     * @param _amountToTransfer total USD amount to be transferred with 18 decimals of precision
     */
    function transactionLimitbyRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);
        uint256 totalRules = data.getTotalTransactionLimitByRiskRules();
        if ((totalRules > 0 && totalRules <= _ruleId) || totalRules == 0) revert RuleDoesNotExist();
        TaggedRules.TransactionSizeToRiskRule memory rule = data.getTransactionLimitByRiskRule(_ruleId);
        ///If risk score is within the rule riskLevel array, find the maxSize for that risk Score
        for (uint256 i; i < rule.riskLevel.length; ) {
            if (_riskScore <= rule.riskLevel[i]) {
                /// maxSize has to be multiplied by 10 ** 18 to take the decimals in the token pricing into account
                if (_amountToTransfer > (uint256(rule.maxSize[i]) * (10 ** 18))) {
                    revert TransactionExceedsRiskScoreLimit();
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
        if (_riskScore > rule.riskLevel[rule.riskLevel.length - 1]) {
            if (_amountToTransfer > uint256(rule.maxSize[rule.maxSize.length - 1]) * (10 ** 18)) revert TransactionExceedsRiskScoreLimit();
        }
    }
}
