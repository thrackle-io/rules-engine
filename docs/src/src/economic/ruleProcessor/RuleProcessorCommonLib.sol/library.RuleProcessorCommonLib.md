# RuleProcessorCommonLib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/d0344b27291308c442daefb74b46bb81740099e4/src/economic/ruleProcessor/RuleProcessorCommonLib.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*stores common functions used throughout the protocol rule checks*


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


## Errors
### InvalidTimestamp

```solidity
error InvalidTimestamp(uint64 _timestamp);
```

