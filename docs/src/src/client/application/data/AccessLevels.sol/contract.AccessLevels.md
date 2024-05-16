# AccessLevels
[Git Source](https://github.com/thrackle-io/tron/blob/a6e068f4bc8dd6e86015430d874759ac1519196d/src/client/application/data/AccessLevels.sol)

**Inherits:**
[IAccessLevels](/src/client/application/data/IAccessLevels.sol/interface.IAccessLevels.md), [DataModule](/src/client/application/data/DataModule.sol/abstract.DataModule.md), [IAppLevelEvents](/src/common/IEvents.sol/interface.IAppLevelEvents.md)

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


### addMultipleAccessLevels

*Add the Access Level(0-4) to the list of account. Restricted to the owner.*


```solidity
function addMultipleAccessLevels(address[] memory _accounts, uint8[] memory _level) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|address array upon which to apply the Access Level|
|`_level`|`uint8[]`|Access Level array to add|


### addAccessLevelToMultipleAccounts

*Add the Access Level(0-4) to multiple accounts. Restricted to the owner.*


```solidity
function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|addresses upon which to apply the Access Level|
|`_level`|`uint8`|Access Level to add|


### getAccessLevel

*Get the Access Level for the account.*


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


### removeAccessLevel

*Remove the Access Level for the account. Restricted to the owner*


```solidity
function removeAccessLevel(address _account) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|


