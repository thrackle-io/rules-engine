# AppRuleDataFacet
[Git Source](https://github.com/thrackle-io/rules-engine/blob/f3baf971c7cb5a9708b7ed14723c3823c9ae4656/src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)

**Inherits:**
Context, [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IEconomicEvents](/src/common/IEvents.sol/interface.IEconomicEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IAppRuleInputErrors](/src/common/IErrors.sol/interface.IAppRuleInputErrors.md), [IRiskInputErrors](/src/common/IErrors.sol/interface.IRiskInputErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract sets and gets the App Rules for the protocol

*Setters and getters for Application level Rules*


## State Variables
### MAX_ACCESSLEVELS

```solidity
uint8 constant MAX_ACCESSLEVELS = 5;
```


### MAX_RISKSCORE

```solidity
uint8 constant MAX_RISKSCORE = 99;
```


## Functions
### addAccountMaxValueByAccessLevel

The position within the array matters. Position 0 represents access level 0,
and position 4 represents level 4.

*Function add an Account Max Value By Access Level rule*

*Function has RuleAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addAccountMaxValueByAccessLevel(address _appManagerAddr, uint48[] calldata _maxValues)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_maxValues`|`uint48[]`|Balance restrictions for each 5 levels from level 0 to 4 in whole USD.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addAccountMaxValueOutByAccessLevel

The position within the array matters. Position 0 represents access level 0,
and position 4 represents level 4.

*Function add an Account Max Value Out By Access Level rule*

*Function has ruleAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addAccountMaxValueOutByAccessLevel(address _appManagerAddr, uint48[] calldata _withdrawalAmounts)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_withdrawalAmounts`|`uint48[]`|withdrawal amaount restrictions for each 5 levels from level 0 to 4 in whole USD.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addAccountMaxTxValueByRiskScore

_maxValue size must be equal to _riskScore.
This means that the positioning of the arrays is ascendant in terms of risk scores,
and descendant in the size of transactions. (i.e. if highest risk scores is 99, the last balanceLimit
will apply to all risk scores of 100.)
eg.
risk scores      balances         resultant logic
-----------      --------         ---------------
0-24  =   NO LIMIT
25              500            25-49 =   500
50              250            50-74 =   250
75              100            75-99 =   100

*Function add an Account Max Transaction Value By Risk Score rule*

*Function has ruleAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addAccountMaxTxValueByRiskScore(
    address _appManagerAddr,
    uint48[] calldata _maxValue,
    uint8[] calldata _riskScore,
    uint16 _period,
    uint64 _startTime
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_maxValue`|`uint48[]`|array of max-tx-size allowed within period (whole USD max values --no cents) Each value in the array represents max USD value transacted within _period, and its positions indicate what range of risk scores it applies to. A value of 1000 here means $1000.00 USD.|
|`_riskScore`|`uint8[]`|array of risk score ceilings that define each range. Risk scores are inclusive.|
|`_period`|`uint16`|amount of hours that each period lasts for. 0 if no period is desired.|
|`_startTime`|`uint64`|start timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addAccountMaxValueByRiskScore

_maxValue size must be equal to _riskScore.
The positioning of the arrays is ascendant in terms of risk score,
and descendant in the size of transactions. (i.e. if highest risk score is 99, the last balanceLimit
will apply to all risk scores of 100.)
eg.
risk scores      balances         resultant logic
-----------      --------         ---------------
0-24  =   NO LIMIT
25              500            25-49 =   500
50              250            50-74 =   250
75              100            75-99 =   100

*Function to add new AccountMaxValueByRiskScore Rules*

*Function has ruleAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addAccountMaxValueByRiskScore(
    address _appManagerAddr,
    uint8[] calldata _riskScores,
    uint48[] calldata _maxValue
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_riskScores`|`uint8[]`|User Risk Score Array|
|`_maxValue`|`uint48[]`|Account Max Value Limit in whole USD for each score range. It corresponds to the _riskScores array. A value of 1000 in this arrays will be interpreted as $1000.00 USD.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### _addAccountMaxValueByRiskScore

*Internal Function to avoid stack too deep error*


```solidity
function _addAccountMaxValueByRiskScore(uint8[] calldata _riskScores, uint48[] calldata _maxValue)
    internal
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_riskScores`|`uint8[]`|Account Risk Score|
|`_maxValue`|`uint48[]`|Account Max Value Limit for each Score in USD (no cents). It corresponds to the _riskScores array. A value of 1000 in this arrays will be interpreted as $1000.00 USD.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


