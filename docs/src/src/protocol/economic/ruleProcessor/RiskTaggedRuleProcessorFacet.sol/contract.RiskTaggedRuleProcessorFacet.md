# RiskTaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/RiskTaggedRuleProcessorFacet.sol)

**Inherits:**
[IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IRiskErrors](/src/common/IErrors.sol/interface.IRiskErrors.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Risk Rules on Tagged Accounts. All risk rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by Handler.*


## Functions
### checkTransactionLimitByRiskScore

_transactionSize size must be equal to _riskScore.
The positioning of the arrays is ascendant in terms of risk levels,
and descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
will apply to all risk scores of 100.)
eg.
risk scores      balances         resultant logic
-----------      --------         ---------------
0-24  =   NO LIMIT
25              500            25-49 =   500
50              250            50-74 =   250
75              100            75-99 =   100

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


### getTransactionLimitByRiskRules

If risk score is less than the first risk score of the rule, there is no limit.
Skips the loop for gas efficiency on low risk scored users

*Function to get the TransactionLimit in the rule set that belongs to an risk score*


```solidity
function getTransactionLimitByRiskRules(uint32 _index)
    public
    view
    returns (TaggedRules.TransactionSizeToRiskRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.TransactionSizeToRiskRule`|balanceAmount balance allowed for access level|


### getTotalTransactionLimitByRiskRule

*Function to get total Transaction Limit by Risk Score rules*


```solidity
function getTotalTransactionLimitByRiskRule() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


