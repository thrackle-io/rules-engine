# Accounts
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/1967bc8c4a91d28c4a17e06555cea67921b90fa3/src/data/Accounts.sol)

**Inherits:**
[DataModule](/src/data/DataModule.sol/contract.DataModule.md), [IAccounts](/src/data/IAccounts.sol/interface.IAccounts.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a storage server for user accounts

*Uses DataModule, which has basic ownable functionality. It will get created, and therefore owned, by the app manager*


## State Variables
### accounts

```solidity
mapping(address => bool) public accounts;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor();
```

### addAccount

*Add the account. Restricted to owner.*


```solidity
function addAccount(address _account) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|user address|


### removeAccount

*Remove the account. Restricted to owner.*


```solidity
function removeAccount(address _account) external onlyOwner;
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


