# IAccessLevels
[Git Source](https://github.com/thrackle-io/tron/blob/12b8f8795779c791ed3113763e21492860614b51/src/client/application/data/IAccessLevels.sol)

**Inherits:**
[IDataModule](/src/client/application/data/IDataModule.sol/interface.IDataModule.md), [IAccessLevelErrors](/src/common/IErrors.sol/interface.IAccessLevelErrors.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

interface to define the functionality of the Access Levels data contract

*Access Level storage and retrieval functions are defined here*


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
|`_level`|`uint8`|access level(0-4)|


### addMultipleAccessLevels

*Add the Access Level(0-4) to the list of account. Restricted to the owner.*


```solidity
function addMultipleAccessLevels(address[] memory _accounts, uint8[] memory _level) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|address array upon which to apply the Access Level|
|`_level`|`uint8[]`|Access Level array to add|


### getAccessLevel

*Get the Access Level for the account.*


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


### addAccessLevelToMultipleAccounts

*Add the Access Level(0-4) to multiple accounts. Restricted to the owner.*


```solidity
function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|addresses upon which to apply the Access Level|
|`_level`|`uint8`|Access Level to add|


### removeAccessLevel

*Remove the Access Level for the account. Restricted to the owner*


```solidity
function removeAccessLevel(address _account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|


