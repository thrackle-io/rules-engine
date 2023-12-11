# RuleProcessorCommonLib
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/RuleProcessorCommonLib.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*stores common functions used throughout the protocol rule checks*


## State Variables
### MAX_TAGS

```solidity
uint8 constant MAX_TAGS = 10;
```


## Functions
### validateTimestamp

*validate a user entered timestamp to ensure that it is valid. Validity depends on it being greater than UNIX epoch and not more than 1 year into the future. It reverts with custom error if invalid*


```solidity
function validateTimestamp(uint64 _startTimestamp) internal view;
```

### checkRuleExistence

*generic function to check the existence of a rule*


```solidity
function checkRuleExistence(uint32 _ruleIndex, uint32 _ruleTotal) internal pure returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleIndex`|`uint32`|index of the current rule|
|`_ruleTotal`|`uint32`|total rules in existence for the rule type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_exists true if it exists, false if not|


### isRuleActive

*Determine is the rule is active. This is only for use in rules that are stored with activation timestamps.*


```solidity
function isRuleActive(uint64 _startTs) internal view returns (bool);
```

### isWithinPeriod

*determine if transaction should be accumulated with the previous or it is a new period which requires reset of accumulators*


```solidity
function isWithinPeriod(uint64 _startTimestamp, uint32 _period, uint64 _lastTransferTs) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_startTimestamp`|`uint64`|the timestamp the rule was enabled|
|`_period`|`uint32`|amount of hours in the rule period|
|`_lastTransferTs`|`uint64`|the last transfer timestamp|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_withinPeriod returns true if current block time is within the rules period, else false.|


### checkMaxTags

if no transactions have happened in the past, it's new

*determine if the max tag number is reached*


```solidity
function checkMaxTags(bytes32[] memory _tags) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tags`|`bytes32[]`|the timestamp the rule was enabled|


### retrieveRiskScoreMaxSize


```solidity
function retrieveRiskScoreMaxSize(uint8 _riskScore, uint8[] memory _riskLevels, uint48[] memory _maxSizes)
    internal
    pure
    returns (uint256);
```

## Errors
### InvalidTimestamp

```solidity
error InvalidTimestamp(uint64 _timestamp);
```

### MaxTagLimitReached

```solidity
error MaxTagLimitReached();
```

### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

