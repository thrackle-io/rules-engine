# DataModule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/1ab1db06d001c0ea3265ec49b85ddd9394430302/src/data/DataModule.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md), Ownable

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a template for all data modules.

*Allows for proper permissioning for both internal and external data sources.*


## State Variables
### dataModuleAppManagerAddress
Data Module


```solidity
address public dataModuleAppManagerAddress;
```


## Functions
### appAdminstratorOrOwnerOnly

*Modifier ensures function caller is a Application Administrators or the parent contract*


```solidity
modifier appAdminstratorOrOwnerOnly();
```

### setAppManagerAddress

only app administrators or owner of this contract can invoke this function successfully.

*updates the dataModuleAppManagerAddress value*


```solidity
function setAppManagerAddress(address _appManagerAddress) external appAdminstratorOrOwnerOnly;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|New address|


### transferDataOwnership

*Transfers ownership of the contract to a new account (`newOwner`).
Can only be called by the current owner.*


```solidity
function transferDataOwnership(address newOwner) public appAdminstratorOrOwnerOnly;
```

