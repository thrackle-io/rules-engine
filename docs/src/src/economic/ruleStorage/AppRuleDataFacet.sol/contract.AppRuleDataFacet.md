# AppRuleDataFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/941799bce65220406b4d9686c5c5f1ae7c99f4ee/src/economic/ruleStorage/AppRuleDataFacet.sol)

**Inherits:**
Context, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IEconomicEvents](/src/interfaces/IEvents.sol/interface.IEconomicEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract sets and gets the App Rules for the protocol

*Setters and getters for App Rules*


## Functions
### addAccessLevelBalanceRule

that position within the array matters. Posotion 0 represents access levellevel 0,
and position 4 represents level 4.

*Function add a AccessLevel Balance rule*

*Function has AppAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addAccessLevelBalanceRule(address _appManagerAddr, uint48[] calldata _balanceAmounts)
    external
    appAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_balanceAmounts`|`uint48[]`|Balance restrictions for each 5 levels from level 0 to 4 in whole USD.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### getAccessLevelBalanceRule

*Function to get the AccessLevel Balance rule in the rule set that belongs to an AccessLevel Level*


```solidity
function getAccessLevelBalanceRule(uint32 _index, uint8 _accessLevel) external view returns (uint48);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accessLevel`|`uint8`|AccessLevel Level to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint48`|balanceAmount balance allowed for access levellevel|


### getTotalAccessLevelBalanceRules

*Function to get total AccessLevel Balance rules*


```solidity
function getTotalAccessLevelBalanceRules() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addMaxTxSizePerPeriodByRiskRule

_maxSize size must be equal to _riskLevel + 1 since the _maxSize must
specify the maximum tx size for anything between the highest risk score and 100
which should be specified in the last position of the _riskLevel. This also
means that the positioning of the arrays is ascendant in terms of risk levels, and
descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
will apply to all risk scores of 100.)

*Function add a Max Tx Size Per Period By Risk rule*

*Function has AppAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addMaxTxSizePerPeriodByRiskRule(
    address _appManagerAddr,
    uint48[] calldata _maxSize,
    uint8[] calldata _riskLevel,
    uint8 _period,
    uint8 _startingTime
) external appAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_maxSize`|`uint48[]`|array of max-tx-size allowed within period (whole USD max values --no cents) Each value in the array represents max USD value transacted within _period, and its positions indicate what range of risk levels it applies to. A value of 1000 here means $1000.00 USD.|
|`_riskLevel`|`uint8[]`|array of risk-level ceilings that define each range. Risk levels are inclusive.|
|`_period`|`uint8`|amount of hours that each period lasts for.|
|`_startingTime`|`uint8`|between 00 and 23 representing the time of the day that the rule starts taking effect. The rule will always start in a date in the past.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### getMaxTxSizePerPeriodRule

Validation block
before creating the rule, we convert the starting time from hour of the day to timestamp date
We create the rule now

*Function to get the Max Tx Size Per Period By Risk rule.*


```solidity
function getMaxTxSizePerPeriodRule(uint32 _index) external view returns (AppRules.TxSizePerPeriodToRiskRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`AppRules.TxSizePerPeriodToRiskRule`|a touple of arrays, a uint8 and a uint64. The first array will be the _maxSize, the second will be the _riskLevel, the uint8 will be the period, and the last value will be the starting date.|


### getTotalMaxTxSizePerPeriodRules

*Function to get total Max Tx Size Per Period By Risk rules*


```solidity
function getTotalMaxTxSizePerPeriodRules() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addAccountBalanceByRiskScore

_maxSize size must be equal to _riskLevel + 1 since the _maxSize must
specify the maximum tx size for anything between the highest risk score and 100
which should be specified in the last position of the _riskLevel. This also
means that the positioning of the arrays is ascendant in terms of risk levels, and
descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
will apply to all risk scores of 100.)

*Function to add new AccountBalanceByRiskScore Rules*

*Function has AppAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addAccountBalanceByRiskScore(
    address _appManagerAddr,
    uint8[] calldata _riskScores,
    uint48[] calldata _balanceLimits
) external appAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_riskScores`|`uint8[]`|User Risk Level Array|
|`_balanceLimits`|`uint48[]`|Account Balance Limit in whole USD for each score range. It corresponds to the _riskScores array and is +1 longer than _riskScores. A value of 1000 in this arrays will be interpreted as $1000.00 USD.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### _addAccountBalanceByRiskScore

*internal Function to avoid stack too deep error*


```solidity
function _addAccountBalanceByRiskScore(uint8[] calldata _riskScores, uint48[] calldata _balanceLimits)
    internal
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_riskScores`|`uint8[]`|Account Risk Level|
|`_balanceLimits`|`uint48[]`|Account Balance Limit for each Score in USD (no cents). It corresponds to the _riskScores array. A value of 1000 in this arrays will be interpreted as $1000.00 USD.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### getAccountBalanceByRiskScore

*Function to get the TransactionLimit in the rule set that belongs to an risk score*


```solidity
function getAccountBalanceByRiskScore(uint32 _index) external view returns (AppRules.AccountBalanceToRiskRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`AppRules.AccountBalanceToRiskRule`|balanceAmount balance allowed for access levellevel|


### getTotalAccountBalanceByRiskScoreRules

*Function to get total Transaction Limit by Risk Score rules*


```solidity
function getTotalAccountBalanceByRiskScoreRules() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


## Errors
### IndexOutOfRange

```solidity
error IndexOutOfRange();
```

### WrongArrayOrder

```solidity
error WrongArrayOrder();
```

### InputArraysSizesNotValid

```solidity
error InputArraysSizesNotValid();
```

### InvalidHourOfTheDay

```solidity
error InvalidHourOfTheDay();
```

### BalanceAmountsShouldHave5Levels

```solidity
error BalanceAmountsShouldHave5Levels(uint8 inputLevels);
```

### RiskLevelCannotExceed99

```solidity
error RiskLevelCannotExceed99();
```

