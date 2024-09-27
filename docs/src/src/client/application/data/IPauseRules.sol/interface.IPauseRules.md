# IPauseRules
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/0c70bcd32f4dcc456508b64e73411cac76dd6f09/src/client/application/data/IPauseRules.sol)

**Inherits:**
[IPauseRuleErrors](/src/common/IErrors.sol/interface.IPauseRuleErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Contains data structure for a pause rule and the interface

*Contains Pause Rule Storage and retrieval function definitions*


## Functions
### addPauseRule

*Add the pause rule to the account. Restricted to the owner*


```solidity
function addPauseRule(uint64 _pauseStart, uint64 _pauseStop) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint64`|pause window start timestamp|
|`_pauseStop`|`uint64`|pause window stop timestamp|


### removePauseRule

*Remove the pause rule from the account. Restricted to the owner*


```solidity
function removePauseRule(uint64 _pauseStart, uint64 _pauseStop) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint64`|pause window start timestamp|
|`_pauseStop`|`uint64`|pause window stop timestamp|


### cleanOutdatedRules

*Cleans up outdated pause rules by removing them from the mapping*


```solidity
function cleanOutdatedRules() external;
```

### getPauseRules

*Get the pauseRules data for a given tokenName.*


```solidity
function getPauseRules() external view returns (PauseRule[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PauseRule[]`|pauseRules all the pause rules for the token|


### isPauseRulesEmpty

return true if pause rules is empty and return false if array contains rules

*Return a bool for if the PauseRule array is empty*


```solidity
function isPauseRulesEmpty() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if empty|


