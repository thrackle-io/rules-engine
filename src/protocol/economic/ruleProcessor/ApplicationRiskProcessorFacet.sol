// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";

/**
 * @title Risk Score Processor Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by an Application Handler.
 * @notice Risk Score Rules. All risk rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract ApplicationRiskProcessorFacet is IInputErrors, IRuleProcessorErrors, IRiskErrors {
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint8; 

    /**
     * @dev Account Max Value By Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _toAddress Address of the recipient
     * @param _riskScore The Risk Score of the recepient account
     * @param _totalValueTo Recipient account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer Total dollar amount to be transferred in USD with 18 decimals of precision
     * @notice _maxValue array size must be equal to _riskScore array size.
     * The positioning of the arrays is ascendant in terms of risk scores,
     * and descendant in the value array. (i.e. if highest risk score is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      balances         resultant logic
     * -----------      --------         ---------------
     *                                   0-24  =   NO LIMIT 
     *    25              500            25-49 =   500
     *    50              250            50-74 =   250
     *    75              100            75-99 =   100
     */
    function checkAccountMaxValueByRiskScore(uint32 _ruleId, address _toAddress, uint8 _riskScore, uint128 _totalValueTo, uint128 _amountToTransfer) external view {
        ApplicationRuleStorage.AccountMaxValueByRiskScore memory rule = getAccountMaxValueByRiskScore(_ruleId);
        uint256 ruleMaxSize;
        /// If recipient address being checked is zero address the rule passes (This allows for burning)
        if (_toAddress != address(0)) {
            if (_riskScore >= rule.riskScore[0]) {
                ruleMaxSize = _riskScore.retrieveRiskScoreMaxSize(rule.riskScore, rule.maxValue);
                if ((_totalValueTo + _amountToTransfer) > ruleMaxSize) revert OverMaxAccValueByRiskScore();
            }
        }
    }

    /**
     * @dev Function to get the Account Max Value By Risk Score rule by index
     * @param _index position of rule in array
     * @return AccountMaxValueByRiskScore rule
     */
    function getAccountMaxValueByRiskScore(uint32 _index) public view returns (ApplicationRuleStorage.AccountMaxValueByRiskScore memory) {
        RuleS.AccountMaxValueByRiskScoreS storage data = Storage.accountMaxValueByRiskScoreStorage();
        _index.checkRuleExistence(getTotalAccountMaxValueByRiskScore());
        if (_index >= data.accountMaxValueByRiskScoreIndex) revert IndexOutOfRange();
        return data.accountMaxValueByRiskScoreRules[_index];
    }

    /**
     * @dev Function to get total Account Max Value By Risk Score rules registered
     * @return Total length of array
     */
    function getTotalAccountMaxValueByRiskScore() public view returns (uint32) {
        RuleS.AccountMaxValueByRiskScoreS storage data = Storage.accountMaxValueByRiskScoreStorage();
        return data.accountMaxValueByRiskScoreIndex;
    }    

    /**
     * @dev Rule that checks if the tx exceeds the limit size in USD for a specific risk profile
     * within a specified period of time.
     * @notice that these max value ranges are set by risk score ranges.
     * @param ruleId to check against.
     * @param _valueTransactedInPeriod the cumulative amount of tokens recorded in the last period.
     * @param txValue in USD of the current transaction with 18 decimals of precision.
     * @param lastTxDate timestamp of the last transfer of this token by this address.
     * @param _riskScore of the address (0 -> 100)
     * @return updated value for the _valueTransactedInPeriod. If _valueTransactedInPeriod are
     * inside the current period, then this value is accumulated. If not, it is reset to current amount.
     * @dev this check will cause a revert if the new value of _valueTransactedInPeriod in USD exceeds
     * the limit for the address risk profile.
     * @notice _maxValue size must be equal to _riskScore 
     * The positioning of the arrays is ascendant in terms of risk scores, 
     * and descendant in the size of transactions. (i.e. if highest risk score is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      balances         resultant logic
     * -----------      --------         ---------------
     *                                   0-24  =   NO LIMIT 
     *    25              500            25-49 =   500
     *    50              250            50-74 =   250
     *    75              100            75-99 =   100
     */
    function checkAccountMaxTxValueByRiskScore(uint32 ruleId, uint128 _valueTransactedInPeriod, uint128 txValue, uint64 lastTxDate, uint8 _riskScore) external view returns (uint128) {
        uint256 ruleMaxSize;
        ApplicationRuleStorage.AccountMaxTxValueByRiskScore memory rule = getAccountMaxTxValueByRiskScore(ruleId);
        uint128 amountTransactedInPeriod = 
            rule.period != 0 && rule.startTime.isWithinPeriod(rule.period, lastTxDate) ? 
            txValue + _valueTransactedInPeriod : txValue;
        
        if (_riskScore >= rule.riskScore[0]) {
            ruleMaxSize = _riskScore.retrieveRiskScoreMaxSize(rule.riskScore, rule.maxValue);
            if (amountTransactedInPeriod > ruleMaxSize) revert OverMaxTxValueByRiskScore(_riskScore, ruleMaxSize);
            return amountTransactedInPeriod;
        } else {
            return amountTransactedInPeriod;
        }
    }

    /**
     * @dev Function to get the Account Max Transaction Value By Risk Score rule.
     * @param _index position of rule in array
     * @return a touple of arrays, a uint8 and a uint64. The first array will be the _maxValue, the second
     * will be the _riskScore, the uint8 will be the period, and the last value will be the starting date.
     */
    function getAccountMaxTxValueByRiskScore(uint32 _index) public view returns (ApplicationRuleStorage.AccountMaxTxValueByRiskScore memory) {
        RuleS.AccountMaxTxValueByRiskScoreS storage data = Storage.accountMaxTxValueByRiskScoreStorage();
        _index.checkRuleExistence(getTotalAccountMaxTxValueByRiskScore());
        if (_index >= data.accountMaxTxValueByRiskScoreIndex) revert IndexOutOfRange();
        return data.accountMaxTxValueByRiskScoreRules[_index];
    }

    /**
     * @dev Function to get total Account Max Transaction Value By Risk Score rules
     * @return Total length of array
     */
    function getTotalAccountMaxTxValueByRiskScore() public view returns (uint32) {
        RuleS.AccountMaxTxValueByRiskScoreS storage data = Storage.accountMaxTxValueByRiskScoreStorage();
        return data.accountMaxTxValueByRiskScoreIndex;
    }
}
