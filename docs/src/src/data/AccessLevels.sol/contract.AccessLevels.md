# AccessLevels
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2955538441cd4ad2d51a27d7c28af7eec4cd8814/src/data/AccessLevels.sol)

**Inherits:**
[IAccessLevels](/src/data/IAccessLevels.sol/interface.IAccessLevels.md), [DataModule](/src/data/DataModule.sol/contract.DataModule.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Data contract to store AccessLevel Levels for user accounts

*This contract stores and serves Access Levels via an internal mapping*


## State Variables
### levels

```solidity
mapping(address => uint8) public levels;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor();
```

### addLevel

*Add the Access Level to the account. Restricted to the owner*


```solidity
function addLevel(address _address, uint8 _level) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the account|
|`_level`|`uint8`|access levellevel(0-4)|


### removelevel

*Remove the Access Level for the account. Restricted to the owner*


```solidity
function removelevel(address _account) external onlyOwner;
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


