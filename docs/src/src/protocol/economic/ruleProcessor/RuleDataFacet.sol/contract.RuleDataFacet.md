# RuleDataFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/RuleDataFacet.sol)

**Inherits:**
Context, [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IEconomicEvents](/src/common/IEvents.sol/interface.IEconomicEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [ITagInputErrors](/src/common/IErrors.sol/interface.ITagInputErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IAppRuleInputErrors](/src/common/IErrors.sol/interface.IAppRuleInputErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract sets and gets the Rules for the protocol

*setters and getters for non tagged token specific rules*


## State Variables
### MAX_TOKEN_PERCENTAGE

```solidity
uint16 constant MAX_TOKEN_PERCENTAGE = 9999;
```


### MAX_PERCENTAGE

```solidity
uint16 constant MAX_PERCENTAGE = 10000;
```


### MAX_VOLUME_PERCENTAGE

```solidity
uint24 constant MAX_VOLUME_PERCENTAGE = 100000;
```


## Functions
### addTokenMaxBuyVolume

Note that no update method is implemented for rules. Since reutilization of
rules is encouraged, it is preferred to add an extra rule to the
set instead of modifying an existing one.
Token Purchase Percentage Getters/Setters **********

*Function to add a Token Purchase Percentage rule*


```solidity
function addTokenMaxBuyVolume(
    address _appManagerAddr,
    uint16 _tokenPercentage,
    uint16 _period,
    uint256 _totalSupply,
    uint64 _startTime
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_tokenPercentage`|`uint16`|Percentage of Tokens allowed to purchase|
|`_period`|`uint16`|Time period that transactions are accumulated|
|`_totalSupply`|`uint256`|total supply of tokens (0 if using total supply from the token contract)|
|`_startTime`|`uint64`|start timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### addTokenMaxSellVolume

Token Sell Percentage Getters/Setters **********

*Function to add a Token Sell Percentage rule*


```solidity
function addTokenMaxSellVolume(
    address _appManagerAddr,
    uint16 _tokenPercentage,
    uint16 _sellPeriod,
    uint256 _totalSupply,
    uint64 _startTime
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_tokenPercentage`|`uint16`|Percent of Tokens allowed to sell|
|`_sellPeriod`|`uint16`|Time period that transactions are frozen|
|`_totalSupply`|`uint256`|total supply of tokens (0 if using total supply from the token contract)|
|`_startTime`|`uint64`|start time for the period|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### addPurchaseFeeByVolumeRule

Token Purchase Fee By Volume Getters/Setters **********

*Function to add a Token Purchase Fee By Volume rule*


```solidity
function addPurchaseFeeByVolumeRule(address _appManagerAddr, uint256 _volume, uint16 _rateIncreased)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_volume`|`uint256`|Maximum allowed volume|
|`_rateIncreased`|`uint16`|Amount rate increased|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getPurchaseFeeByVolumeRule

*Function get Token PurchaseFeeByVolume Rule by index*


```solidity
function getPurchaseFeeByVolumeRule(uint32 _index)
    external
    view
    returns (NonTaggedRules.TokenPurchaseFeeByVolume memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenPurchaseFeeByVolume`|TokenPurchaseFeeByVolume rule at index position|


### getTotalTokenPurchaseFeeByVolumeRules

*Function to get total Token Purchase Percentage*


```solidity
function getTotalTokenPurchaseFeeByVolumeRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addTokenMaxPriceVolatility

Token Volatility Getters/Setters **********

*Function to add a Token Volatility rule*


```solidity
function addTokenMaxPriceVolatility(
    address _appManagerAddr,
    uint16 _max,
    uint16 _period,
    uint16 _hoursFrozen,
    uint256 _totalSupply
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_max`|`uint16`|Maximum allowed volume|
|`_period`|`uint16`|period in hours for the rule|
|`_hoursFrozen`|`uint16`|freeze period hours|
|`_totalSupply`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getTokenMaxPriceVolatility

*Function get Token Volatility Rule by index*


```solidity
function getTokenMaxPriceVolatility(uint32 _index) external view returns (NonTaggedRules.TokenMaxPriceVolatility memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenMaxPriceVolatility`|tokenMaxPriceVolatilityRules rule at index position|


### getTotalTokenMaxPriceVolatility

*Function to get total Volatility rules*


```solidity
function getTotalTokenMaxPriceVolatility() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addTokenMaxTradingVolume

Token Transfer Volume Getters/Setters **********

*Function to add a Token transfer Volume rules*


```solidity
function addTokenMaxTradingVolume(
    address _appManagerAddr,
    uint24 _maxPercentage,
    uint16 _hoursPerPeriod,
    uint64 _startTime,
    uint256 _totalSupply
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_maxPercentage`|`uint24`|Maximum allowed volume percentage (this is 4 digits to allow 2 decimal places)|
|`_hoursPerPeriod`|`uint16`|Allowed hours per period|
|`_startTime`|`uint64`|Timestamp to start the rule|
|`_totalSupply`|`uint256`|Circulating supply value to use in calculations. If not specified, defaults to ERC20 totalSupply|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### addTokenMinTransactionSize

Minimum Transfer Rule Getters/Setters **********

*Function to add Min Transfer rules*


```solidity
function addTokenMinTransactionSize(address _appManagerAddr, uint256 _minimumTransfer)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_minimumTransfer`|`uint256`|Mimimum amount of tokens required for transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### addSupplyVolatilityRule

Supply Volatility Getters/Setters **********

*Function Token Supply Volatility rules*


```solidity
function addSupplyVolatilityRule(
    address _appManagerAddr,
    uint16 _maxPercentage,
    uint16 _period,
    uint64 _startTime,
    uint256 _totalSupply
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_maxPercentage`|`uint16`|Maximum amount of change allowed. This is not capped and will allow for values greater than 100%. Since there is no cap for _maxPercentage this could allow burning of full totalSupply() if over 100% (10000).|
|`_period`|`uint16`|Allowed hours per period|
|`_startTime`|`uint64`|Unix timestamp for the _period to start counting.|
|`_totalSupply`|`uint256`|this is an optional parameter. If 0, the toalSupply will be calculated dyamically. If not zero, this is going to be the locked value to calculate the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### addAccountApproveDenyOracle

Oracle Getters/Setters **********

*Function add an Oracle rule*


```solidity
function addAccountApproveDenyOracle(address _appManagerAddr, uint8 _type, address _oracleAddress)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_type`|`uint8`|type of Oracle Rule --> 0 = restricted; 1 = allowed|
|`_oracleAddress`|`address`|Address of Oracle|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of rule in storage|


