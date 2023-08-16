# PauseRules
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/d0344b27291308c442daefb74b46bb81740099e4/src/data/PauseRules.sol)

**Inherits:**
[IPauseRules](/src/data/IPauseRules.sol/interface.IPauseRules.md), [DataModule](/src/data/DataModule.sol/abstract.DataModule.md)

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
constructor(address _dataModuleAppManagerAddress) DataModule(dataModuleAppManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataModuleAppManagerAddress`|`address`|address of the owning app manager|


### addPauseRule

*Add the pause rule to the account. Restricted to the owner*


```solidity
function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) public virtual onlyOwner;
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
function removePauseRule(uint256 _pauseStart, uint256 _pauseStop) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint256`|pause window start timestamp|
|`_pauseStop`|`uint256`|pause window stop timestamp|


### cleanOutdatedRules

*Cleans up outdated pause rules by removing them from the mapping*


```solidity
function cleanOutdatedRules() public virtual;
```

### getPauseRules

*Get the pauseRules data for a given tokenName.*


```solidity
function getPauseRules() external view virtual onlyOwner returns (PauseRule[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PauseRule[]`|pauseRules all the pause rules for the token|


