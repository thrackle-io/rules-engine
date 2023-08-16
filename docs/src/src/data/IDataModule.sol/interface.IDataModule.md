# IDataModule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/d0344b27291308c442daefb74b46bb81740099e4/src/data/IDataModule.sol)

**Inherits:**
[IAppLevelEvents](/src/interfaces/IEvents.sol/interface.IAppLevelEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a template for all data modules.

*Allows for proper permissioning for both internal and external data sources.*


## Functions
### proposeOwner

*this function proposes a new owner that is put in storage to be confirmed in a separate process*


```solidity
function proposeOwner(address _newOwner) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|the new address being proposed|


### confirmOwner

*this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address*


```solidity
function confirmOwner() external;
```

### confirmDataProvider

*Part of the two step process to set a new Data Provider within a Protocol AppManager*


```solidity
function confirmDataProvider(ProviderType _providerType) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_providerType`|`ProviderType`|the type of data provider|


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

## Enums
### ProviderType

```solidity
enum ProviderType {
    ACCESS_LEVEL,
    ACCOUNT,
    GENERAL_TAG,
    PAUSE_RULE,
    RISK_SCORE
}
```

