# AccessLevels
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/client/application/data/AccessLevels.sol)

**Inherits:**
[IAccessLevels](/src/client/application/data/IAccessLevels.sol/interface.IAccessLevels.md), [DataModule](/src/client/application/data/DataModule.sol/abstract.DataModule.md)

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
constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataModuleAppManagerAddress`|`address`|address of the owning app manager|


### addLevel

*Add the Access Level to the account. Restricted to the owner*


```solidity
function addLevel(address _address, uint8 _level) public virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the account|
|`_level`|`uint8`|access level(0-4)|


### addAccessLevelToMultipleAccounts

*Add the Access Level(0-4) to multiple accounts. Restricted to Access Tiers.*


```solidity
function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|address upon which to apply the Access Level|
|`_level`|`uint8`|Access Level to add|


### getAccessLevel

*Get the Access Level for the account. Restricted to the owner*


```solidity
function getAccessLevel(address _account) external view virtual returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|level Access Level(0-4)|


