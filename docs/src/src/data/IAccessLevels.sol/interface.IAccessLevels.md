# IAccessLevels
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4f7789968960e18493ff0b85b09856f12969daac/src/data/IAccessLevels.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

interface to define the functionality of the AccessLevel Levels data contract

*AccessLevel score storage and retrieval functions are defined here*


## Functions
### addLevel

*Add the Access Level to the account. Restricted to the owner*


```solidity
function addLevel(address _address, uint8 _level) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the account|
|`_level`|`uint8`|access levellevel(0-4)|


### removelevel

*Remove the Access Level for the account. Restricted to the owner*


```solidity
function removelevel(address _account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|


### getAccessLevel

*Get the Access Level for the account. Restricted to the owner*


```solidity
function getAccessLevel(address _account) external view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|level Access Level(0-4)|


### hasAccessLevel

*Check if an account has a Access Level*


```solidity
function hasAccessLevel(address _address) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|hasAccessLevel true if it has a level, false if it doesn't|


