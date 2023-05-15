# IDataModule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/data/IDataModule.sol)

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

