# PauseRules
[Git Source](https://github.com/thrackle-io/tron/blob/a0e7b20980bb06404eb010a144cfad3764962831/src/client/application/data/PauseRules.sol)

**Inherits:**
[IPauseRules](/src/client/application/data/IPauseRules.sol/interface.IPauseRules.md), [DataModule](/src/client/application/data/DataModule.sol/abstract.DataModule.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Data contract to store Pause rules for the application

*This contract stores and serves pause rules via an internal mapping*


## State Variables
### pauseRules

```solidity
PauseRule[] private pauseRules;
```


### MAX_RULES

```solidity
uint8 constant MAX_RULES = 15;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataModuleAppManagerAddress`|`address`|address of the owning app manager|


### addPauseRule

*Add the pause rule to the account. Restricted to the owner*


```solidity
function addPauseRule(uint64 _pauseStart, uint64 _pauseStop) public virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint64`|pause window start timestamp|
|`_pauseStop`|`uint64`|pause window stop timestamp|


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
function removePauseRule(uint64 _pauseStart, uint64 _pauseStop) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint64`|pause window start timestamp|
|`_pauseStop`|`uint64`|pause window stop timestamp|


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


### isPauseRulesEmpty

return true if pause rules is empty and return false if array contains rules

*Return a bool for if the PauseRule array is empty*


```solidity
function isPauseRulesEmpty() external view virtual onlyOwner returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if empty|


