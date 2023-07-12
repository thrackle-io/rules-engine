# IPauseRules
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/2eb992c5f8a67ecb6f7fb3675bc386aaa483c728/src/data/IPauseRules.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md), [IPauseRuleErrors](/src/interfaces/IErrors.sol/interface.IPauseRuleErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Contains data structure for a pause rule and the interface

*Contains Pause Rule Storage and retrieval function definitions*


## Functions
### addPauseRule

*Add the pause rule to the account. Restricted to the owner*


```solidity
function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint256`|pause window start timestamp|
|`_pauseStop`|`uint256`|pause window stop timestamp|


### removePauseRule

*Remove the pause rule from the account. Restricted to the owner*


```solidity
function removePauseRule(uint256 _pauseStart, uint256 _pauseStop) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint256`|pause window start timestamp|
|`_pauseStop`|`uint256`|pause window stop timestamp|


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


