# ApplicationRiskProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/570e509b7dae1b89ffe858956bb3df9bbac2510a/src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol)

**Inherits:**
[IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IRiskErrors](/src/common/IErrors.sol/interface.IRiskErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Risk Score Rules. All risk rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by an Application Handler.*


## Functions
### checkAccountMaxValueByRiskScore

_maxValue array size must be equal to _riskScore array size.
The positioning of the arrays is ascendant in terms of risk scores,
and descendant in the value array. (i.e. if highest risk score is 99, the last balanceLimit
will apply to all risk scores of 100.)
eg.
risk scores      balances         resultant logic
-----------      --------         ---------------
0-24  =   NO LIMIT
25              500            25-49 =   500
50              250            50-74 =   250
75              100            75-99 =   100

*Account Max Value By Risk Score*


```solidity
function checkAccountMaxValueByRiskScore(
    uint32 _ruleId,
    address _toAddress,
    uint8 _riskScore,
    uint128 _totalValueTo,
    uint128 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_toAddress`|`address`|Address of the recipient|
|`_riskScore`|`uint8`|The Risk Score of the recepient account|
|`_totalValueTo`|`uint128`|Recipient account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|Total dollar amount to be transferred in USD with 18 decimals of precision|


### getAccountMaxValueByRiskScore

If recipient address being checked is zero address the rule passes (This allows for burning)

*Function to get the Account Max Value By Risk Score rule by index*


```solidity
function getAccountMaxValueByRiskScore(uint32 _index)
    public
    view
    returns (ApplicationRuleStorage.AccountMaxValueByRiskScore memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`ApplicationRuleStorage.AccountMaxValueByRiskScore`|AccountMaxValueByRiskScore rule|


### getTotalAccountMaxValueByRiskScore

*Function to get total Account Max Value By Risk Score rules registered*


```solidity
function getTotalAccountMaxValueByRiskScore() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkAccountMaxTxValueByRiskScore

that these max value ranges are set by risk score ranges.

_maxValue size must be equal to _riskScore
The positioning of the arrays is ascendant in terms of risk scores,
and descendant in the size of transactions. (i.e. if highest risk score is 99, the last balanceLimit
will apply to all risk scores of 100.)
eg.
risk scores      balances         resultant logic
-----------      --------         ---------------
0-24  =   NO LIMIT
25              500            25-49 =   500
50              250            50-74 =   250
75              100            75-99 =   100

*Rule that checks if the tx exceeds the limit size in USD for a specific risk profile
within a specified period of time.*

*this check will cause a revert if the new value of _valueTransactedInPeriod in USD exceeds
the limit for the address risk profile.*


```solidity
function checkAccountMaxTxValueByRiskScore(
    uint32 ruleId,
    uint128 _valueTransactedInPeriod,
    uint128 txValue,
    uint64 lastTxDate,
    uint8 _riskScore
) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|to check against.|
|`_valueTransactedInPeriod`|`uint128`|the cumulative amount of tokens recorded in the last period.|
|`txValue`|`uint128`|in USD of the current transaction with 18 decimals of precision.|
|`lastTxDate`|`uint64`|timestamp of the last transfer of this token by this address.|
|`_riskScore`|`uint8`|of the address (0 -> 100)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|updated value for the _valueTransactedInPeriod. If _valueTransactedInPeriod are inside the current period, then this value is accumulated. If not, it is reset to current amount.|


### getAccountMaxTxValueByRiskScore

*Function to get the Account Max Transaction Value By Risk Score rule.*


```solidity
function getAccountMaxTxValueByRiskScore(uint32 _index)
    public
    view
    returns (ApplicationRuleStorage.AccountMaxTxValueByRiskScore memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`ApplicationRuleStorage.AccountMaxTxValueByRiskScore`|a touple of arrays, a uint8 and a uint64. The first array will be the _maxValue, the second will be the _riskScore, the uint8 will be the period, and the last value will be the starting date.|


### getTotalAccountMaxTxValueByRiskScore

*Function to get total Account Max Transaction Value By Risk Score rules*


```solidity
function getTotalAccountMaxTxValueByRiskScore() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


