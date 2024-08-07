# PauseRules
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/f3f89426d30f93406f5ff447f7284dbf958844b4/src/client/application/data/PauseRules.sol)

**Inherits:**
[IPauseRules](/src/client/application/data/IPauseRules.sol/interface.IPauseRules.md), [DataModule](/src/client/application/data/DataModule.sol/abstract.DataModule.md), [IAppLevelEvents](/src/common/IEvents.sol/interface.IAppLevelEvents.md)

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

This function first cleans outdated rules, then checks if new pause rule will exceed the MAX_RULES limit (15)

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

Function loops through pause rules while there is at least 1 stored rule. Then calls _removePauseRule() for all rules whose end date is less than or equal to block.timestamp.
This loop will continue looping through (a maximum of 15 rules) until all rules are "swapped and popped" in order to remove outdated rules, even when not stored in dated order.

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

Function loops through pause rules and calls _removePauseRule() for all rules whose end date is less than or equal to block.timestamp
This loop will continue looping through (a maximum of 15 rules) until all rules are "swapped and popped" in order to remove outdated rules, even when not stored in dated order.

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


