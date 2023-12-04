// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";
import {TaggedRuleDataFacet} from "./TaggedRuleDataFacet.sol";


/**
 * @title Risk Rules Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements Risk Rules on Tagged Accounts. All risk rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract RiskTaggedRuleProcessorFacet is IRuleProcessorErrors, IRiskErrors, IInputErrors {
    using RuleProcessorCommonLib for uint8; 
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    /**
     * @dev Transaction Limit for Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _riskScore the Risk Score of the account
     * @param _amountToTransfer total USD amount to be transferred with 18 decimals of precision
     * @notice _transactionSize size must be equal to _riskLevel.
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
    function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) external view {
        uint256 ruleMaxSize;
        TaggedRules.TransactionSizeToRiskRule memory rule = getTransactionLimitByRiskRules(_ruleId);
        /// If risk score is less than the first risk score of the rule, there is no limit. 
        /// Skips the loop for gas efficiency on low risk scored users 
        if (_riskScore >= rule.riskLevel[0]) {
            ruleMaxSize = _riskScore.retrieveRiskScoreMaxSize(rule.riskLevel, rule.maxSize);
            if (_amountToTransfer > ruleMaxSize) revert TransactionExceedsRiskScoreLimit();
        }
    }

    /**
     * @dev Function to get the TransactionLimit in the rule set that belongs to an risk score
     * @param _index position of rule in array
     * @return balanceAmount balance allowed for access levellevel
     */
    function getTransactionLimitByRiskRules(uint32 _index) public view returns (TaggedRules.TransactionSizeToRiskRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalTransactionLimitByRiskRule());
        RuleS.TxSizeToRiskRuleS storage data = Storage.txSizeToRiskStorage();
        if (_index >= data.txSizeToRiskRuleIndex) revert IndexOutOfRange();
        return data.txSizeToRiskRule[_index];
    }

    /**
     * @dev Function to get total Transaction Limit by Risk Score rules
     * @return Total length of array
     */
    function getTotalTransactionLimitByRiskRule() public view returns (uint32) {
        RuleS.TxSizeToRiskRuleS storage data = Storage.txSizeToRiskStorage();
        return data.txSizeToRiskRuleIndex;
    }
}
