# DataModule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4f7789968960e18493ff0b85b09856f12969daac/src/data/DataModule.sol)

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

