# ApplicationRiskProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/a2d57139b7236b5b0e9a0727e55f81e5332cd216/src/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol)

**Inherits:**
[IRuleProcessorErrors](/src/interfaces/IErrors.sol/interface.IRuleProcessorErrors.md), [IRiskErrors](/src/interfaces/IErrors.sol/interface.IRiskErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Risk Score Rules. All risk rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by Handler.*


## Functions
### checkAccBalanceByRisk

_balanceLimits size must be equal to _riskLevel + 1 since the _balanceLimits must
specify the maximum tx size for anything below the first level and between the highest risk score and 100. This also
means that the positioning of the arrays is ascendant in terms of risk levels, and
descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
will apply to all risk scores of 100.)
eg.
risk scores      balances         resultant logic
-----------      --------         ---------------
25             1000            0-24  =  1000
50              500            25-49 =   500
75              250            50-74 =   250
100            75-99 =   100

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


### checkMaxTxSizePerPeriodByRisk

create the 'data' variable which is simply a connection to the rule diamond
retrieve the rule
perform the rule check
If recipient address being checked is zero address the rule passes (This allows for burning)
If risk score is within the rule riskLevel array, find the maxBalance for that risk Score
maxBalance must be multiplied by 10 ** 18 to account for decimals in token pricing in USD
Jump out of loop once risk score is matched to array index
Check if Risk Score is higher than highest riskLevel for rule

that these ranges are set by ranges.

_balanceLimits size must be equal to _riskLevel + 1 since the _balanceLimits must
specify the maximum tx size for anything below the first level and between the highest risk score and 100. This also
means that the positioning of the arrays is ascendant in terms of risk levels, and
descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
will apply to all risk scores of 100.)
eg.
risk scores      balances         resultant logic
-----------      --------         ---------------
25             1000            0-24  =  1000
50              500            25-49 =   500
75              250            50-74 =   250
100            75-99 =   100

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


