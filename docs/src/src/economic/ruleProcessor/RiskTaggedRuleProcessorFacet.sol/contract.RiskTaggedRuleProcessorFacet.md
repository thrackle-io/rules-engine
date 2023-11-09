# RiskTaggedRuleProcessorFacet
<<<<<<< HEAD
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/economic/ruleProcessor/RiskTaggedRuleProcessorFacet.sol)
=======
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/economic/ruleProcessor/RiskTaggedRuleProcessorFacet.sol)
>>>>>>> external

**Inherits:**
[IRuleProcessorErrors](/src/interfaces/IErrors.sol/interface.IRuleProcessorErrors.md), [IRiskErrors](/src/interfaces/IErrors.sol/interface.IRiskErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Risk Rules on Tagged Accounts. All risk rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by Handler.*


## Functions
### checkTransactionLimitByRiskScore

_transactionSize size must be equal to _riskLevel + 1 since the _transactionSize must
specify the maximum tx size for anything below the first level and between the highest risk score and 100. This also
means that the positioning of the arrays is ascendant in terms of risk levels, and
descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
will apply to all risk scores of 100.)
eg.
risk scores      TxLimit         resultant logic
-----------      --------         ---------------
25             1000            0-24  =  1000
50              500            25-49 =   500
75              250            50-74 =   250
100            75-99 =   100

*Transaction Limit for Risk Score*


```solidity
function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_riskScore`|`uint8`|the Risk Score of the account|
|`_amountToTransfer`|`uint256`|total USD amount to be transferred with 18 decimals of precision|


