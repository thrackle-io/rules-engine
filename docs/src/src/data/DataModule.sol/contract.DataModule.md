# DataModule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/b3877670eae43a9723081d42c4401502ebd5b9f6/src/data/DataModule.sol)

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


```solidity
function setAppManagerAddress(address _appManagerAddress) external appAdminstratorOrOwnerOnly;
```

### transferDataOwnership

*Transfers ownership of the contract to a new account (`newOwner`).
Can only be called by the current owner.*


```solidity
function transferDataOwnership(address newOwner) public appAdminstratorOrOwnerOnly;
```

