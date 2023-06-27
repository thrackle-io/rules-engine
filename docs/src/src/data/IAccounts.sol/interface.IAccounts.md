# IAccounts
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/121468a758a67e73dd1df571fd4e956242c3c973/src/data/IAccounts.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md)

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


