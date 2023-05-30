# ApplicationRiskProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/49ab19f6a1a98efed1de2dc532ff3da9b445a7cb/src/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Risk Score Rules on  Tagged Accounts. All risk rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by Handler.*


## Functions
### checkAccBalanceByRisk

*Account balance for Risk Score*


```solidity
function checkAccBalanceByRisk(uint32 _ruleId, uint8 _riskScore, uint128 _totalValuationTo, uint128 _amountToTransfer)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_riskScore`|`uint8`|the Risk Score of the recepient account|
|`_totalValuationTo`|`uint128`|recepient account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total dollar amount to be transferred in USD with 18 decimals of precision|


### checkMaxTxSizePerPeriodByRisk

we create the 'data' variable which is simply a connection to the rule diamond
validation block
we procede to retrieve the rule
we perform the rule check
If risk score is within the rule riskLevel array, find the maxBalance for that risk Score
maxBalance must be multiplied by 10 ** 18 to account for decimals in token pricing in USD
Jump out of loop once risk score is matched to array index
Check if Risk Score is higher than highest riskLevel for rule

that these ranges are set by ranges.

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
    uint8 riskScore
) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|to check against.|
|`_usdValueTransactedInPeriod`|`uint128`|the cumulative amount of tokens recorded in the last period.|
|`amount`|`uint128`|in USD of the current transaction with 18 decimals of precision.|
|`lastTxDate`|`uint64`|timestamp of the last transfer of this token by this address.|
|`riskScore`|`uint8`|of the address (0 -> 100)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|updated value for the _usdValueTransactedInPeriod. If _usdValueTransactedInPeriod are inside the current period, then this value is accumulated. If not, it is reset to current amount.|


## Errors
### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

### MaxTxSizePerPeriodReached

```solidity
error MaxTxSizePerPeriodReached(uint8 riskScore, uint256 maxTxSize, uint8 hoursOfPeriod);
```

### TransactionExceedsRiskScoreLimit

```solidity
error TransactionExceedsRiskScoreLimit();
```

### BalanceExceedsRiskScoreLimit

```solidity
error BalanceExceedsRiskScoreLimit();
```

