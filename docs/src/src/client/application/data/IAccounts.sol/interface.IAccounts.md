# IAccounts
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/client/application/data/IAccounts.sol)

**Inherits:**
[IDataModule](/src/client/application/data/IDataModule.sol/interface.IDataModule.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a storage server for user accounts

*Uses IDataModule, which has basic ownable functionality. It will get created, and therefore owned, by the app manager*


## Functions
### addAccount

*Add the account. Restricted to owner.*


```solidity
function addAccount(address _account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|user address|


### removeAccount

*Remove the account. Restricted to owner.*


```solidity
function removeAccount(address _account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|user address|


### isUserAccount

*Checks to see if the account exists*


```solidity
function isUserAccount(address _address) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|exists true if exists, false if not exists|


