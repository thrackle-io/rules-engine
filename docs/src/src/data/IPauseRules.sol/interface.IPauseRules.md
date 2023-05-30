# IPauseRules
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/49ab19f6a1a98efed1de2dc532ff3da9b445a7cb/src/data/IPauseRules.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md)

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


