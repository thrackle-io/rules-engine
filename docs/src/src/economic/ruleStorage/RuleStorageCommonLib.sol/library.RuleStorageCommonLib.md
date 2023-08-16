# RuleStorageCommonLib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/economic/ruleStorage/RuleStorageCommonLib.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*stores common functions used throughout the protocol rule data storage*


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


## Errors
### InvalidTimestamp

```solidity
error InvalidTimestamp(uint64 _timestamp);
```

### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

