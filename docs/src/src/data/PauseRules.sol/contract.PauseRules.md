# PauseRules
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4e5c0bf97c314267dd6acccac5053bfaa6859607/src/data/PauseRules.sol)

**Inherits:**
[IPauseRules](/src/data/IPauseRules.sol/interface.IPauseRules.md), [DataModule](/src/data/DataModule.sol/contract.DataModule.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Data contract to store Pause for user accounts

*This contract stores and serves pause rules via an internal mapping*


## State Variables
### pauseRules

```solidity
PauseRule[] private pauseRules;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor();
```

### addPauseRule

*Add the pause rule to the account. Restricted to the owner*


```solidity
function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint256`|pause window start timestamp|
|`_pauseStop`|`uint256`|pause window stop timestamp|


### _removePauseRule

*Helper function to remove pause rule*


```solidity
function _removePauseRule(uint256 i) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`i`|`uint256`|index of pause rule to remove|


### removePauseRule

*Remove the pause rule from the account. Restricted to the owner*


```solidity
function removePauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint256`|pause window start timestamp|
|`_pauseStop`|`uint256`|pause window stop timestamp|


### cleanOutdatedRules

*Cleans up outdated pause rules by removing them from the mapping*


```solidity
function cleanOutdatedRules() public;
```

### getPauseRules

*Get the pauseRules data for a given tokenName.*


```solidity
function getPauseRules() external view onlyOwner returns (PauseRule[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PauseRule[]`|pauseRules all the pause rules for the token|


