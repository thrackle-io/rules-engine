// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RuleProcessorDiamondLib as Diamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {TaggedRuleDataFacet} from "../ruleStorage/TaggedRuleDataFacet.sol";
import {ITaggedRules as TaggedRules} from "../ruleStorage/RuleDataInterfaces.sol";
import {IRuleProcessorErrors, IRiskErrors} from "../../interfaces/IErrors.sol";

/**
 * @title Risk Rules Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements Risk Rules on Tagged Accounts. All risk rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract RiskTaggedRuleProcessorFacet is IRuleProcessorErrors, IRiskErrors {
   

    /**
     * @dev Transaction Limit for Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _riskScore the Risk Score of the account
     * @param _amountToTransfer total USD amount to be transferred with 18 decimals of precision
     * @notice _transactionSize size must be equal to _riskLevel + 1 since the _transactionSize must
     * specify the maximum tx size for anything below the first level and between the highest risk score and 100. This also
     * means that the positioning of the arrays is ascendant in terms of risk levels, and
     * descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      TxLimit         resultant logic
     * -----------      --------         ---------------
     *    25             1000            0-24  =  1000
     *    50              500            25-49 =   500
     *    75              250            50-74 =   250
     *                    100            75-99 =   100
     */
    function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        uint256 totalRules = data.getTotalTransactionLimitByRiskRules();
        if ((totalRules > 0 && totalRules <= _ruleId) || totalRules == 0) revert RuleDoesNotExist();
        TaggedRules.TransactionSizeToRiskRule memory rule = data.getTransactionLimitByRiskRule(_ruleId);
        ///If risk score is within the rule riskLevel array, find the maxSize for that risk Score
        for (uint256 i; i < rule.riskLevel.length; ) {
            if (_riskScore < rule.riskLevel[i]) {
                /// maxSize has to be multiplied by 10 ** 18 to take the decimals in the token pricing into account
                if (_amountToTransfer > uint256(rule.maxSize[i]) * (10 ** 18)) {
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
        if (_riskScore >= rule.riskLevel[rule.riskLevel.length - 1]) {
            if (_amountToTransfer > uint256(rule.maxSize[rule.maxSize.length - 1]) * (10 ** 18)) revert TransactionExceedsRiskScoreLimit();
        }
    }
}
