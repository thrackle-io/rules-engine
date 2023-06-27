# IDataModule
[Git Source](https://github.com/thrackle-io/Tron/blob/68f4a826ed4aff2c87e6d1264dce053ee793c987/src/data/IDataModule.sol)

**Inherits:**
[IAppLevelEvents](/src/interfaces/IEvents.sol/interface.IAppLevelEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a template for all data modules.

*Allows for proper permissioning for both internal and external data sources.*


## Functions
### setAppManagerAddress


```solidity
function setAppManagerAddress(address _appManagerAddress) external;
```

### transferDataOwnership

*Transfers ownership of the contract to a new account (`newOwner`).
Can only be called by the current owner.*


```solidity
function transferDataOwnership(address newOwner) external;
```

## Errors
### AppManagerNotConnected
Data Module


```solidity
error AppManagerNotConnected();
```

### NotAppAdministratorOrOwner

```solidity
error NotAppAdministratorOrOwner();
```

