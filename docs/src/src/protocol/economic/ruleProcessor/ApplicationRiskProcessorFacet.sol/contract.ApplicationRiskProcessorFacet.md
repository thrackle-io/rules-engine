# ApplicationRiskProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol)

**Inherits:**
[IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IRiskErrors](/src/common/IErrors.sol/interface.IRiskErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Risk Score Rules. All risk rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by Handler.*


## Functions
### checkAccBalanceByRisk

_balanceLimits size must be equal to _riskLevel.
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

*Account balance by Risk Score*


```solidity
function checkAccBalanceByRisk(
    uint32 _ruleId,
    address _toAddress,
    uint8 _riskScore,
    uint128 _totalValuationTo,
    uint128 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_toAddress`|`address`|Address of the recipient|
|`_riskScore`|`uint8`|the Risk Score of the recepient account|
|`_totalValuationTo`|`uint128`|recipient account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total dollar amount to be transferred in USD with 18 decimals of precision|


### getAccountBalanceByRiskScore

retrieve the rule
perform the rule check
If recipient address being checked is zero address the rule passes (This allows for burning)
If risk score is less than the first risk score of the rule, there is no limit.
Skips the loop for gas efficiency on low risk scored users

*Function to get the TransactionLimit in the rule set that belongs to an risk score*


```solidity
function getAccountBalanceByRiskScore(uint32 _index)
    public
    view
    returns (ApplicationRuleStorage.AccountBalanceToRiskRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`ApplicationRuleStorage.AccountBalanceToRiskRule`|balanceAmount balance allowed for access levellevel|


### getTotalAccountBalanceByRiskScoreRules

*Function to get total Transaction Limit by Risk Score rules*


```solidity
function getTotalAccountBalanceByRiskScoreRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkMaxTxSizePerPeriodByRisk

that these ranges are set by ranges.

_balanceLimits size must be equal to _riskLevel
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

*rule that checks if the tx exceeds the limit size in USD for a specific risk profile
within a specified period of time.*

*this check will cause a revert if the new value of _usdValueTransactedInPeriod in USD exceeds
the limit for the address risk profile.*


```solidity
function checkMaxTxSizePerPeriodByRisk(
    uint32 ruleId,
    uint128 _usdValueTransactedInPeriod,
    uint128 amount,
    uint64 lastTxDate,
    uint8 _riskScore
) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|to check against.|
|`_usdValueTransactedInPeriod`|`uint128`|the cumulative amount of tokens recorded in the last period.|
|`amount`|`uint128`|in USD of the current transaction with 18 decimals of precision.|
|`lastTxDate`|`uint64`|timestamp of the last transfer of this token by this address.|
|`_riskScore`|`uint8`|of the address (0 -> 100)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|updated value for the _usdValueTransactedInPeriod. If _usdValueTransactedInPeriod are inside the current period, then this value is accumulated. If not, it is reset to current amount.|


### getMaxTxSizePerPeriodRule

we retrieve the rule
resetting the "tradesWithinPeriod", unless we have been in current period for longer than the last update
If risk score is less than the first risk score of the rule, there is no limit.
Skips the loop for gas efficiency on low risk scored users

*Function to get the Max Tx Size Per Period By Risk rule.*


```solidity
function getMaxTxSizePerPeriodRule(uint32 _index)
    public
    view
    returns (ApplicationRuleStorage.TxSizePerPeriodToRiskRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`ApplicationRuleStorage.TxSizePerPeriodToRiskRule`|a touple of arrays, a uint8 and a uint64. The first array will be the _maxSize, the second will be the _riskLevel, the uint8 will be the period, and the last value will be the starting date.|


### getTotalMaxTxSizePerPeriodRules

*Function to get total Max Tx Size Per Period By Risk rules*


```solidity
function getTotalMaxTxSizePerPeriodRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


