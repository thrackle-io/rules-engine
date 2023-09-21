# RuleProcessorCommonLib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/108c58e2bb8e5c2e5062cebb48a41dcaadcbfcd8/src/economic/ruleProcessor/RuleProcessorCommonLib.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*stores common functions used throughout the protocol rule checks*


## State Variables
### MAX_TAGS

```solidity
uint8 constant MAX_TAGS = 10;
```


## Functions
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


## Errors
### InvalidTimestamp

```solidity
error InvalidTimestamp(uint64 _timestamp);
```

### MaxTagLimitReached

```solidity
error MaxTagLimitReached();
```

