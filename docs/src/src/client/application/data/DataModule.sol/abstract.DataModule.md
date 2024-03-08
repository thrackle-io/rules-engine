# DataModule
[Git Source](https://github.com/thrackle-io/tron/blob/baac0bbfdefb8a299b09493a3979f2ef5c07be0f/src/client/application/data/DataModule.sol)

**Inherits:**
[IDataModule](/src/client/application/data/IDataModule.sol/interface.IDataModule.md), Ownable, [IOwnershipErrors](/src/common/IErrors.sol/interface.IOwnershipErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a template for all data modules and is abstract as it is not intended to be deployed on its own.

*Allows for proper permissioning for both internal and external data sources.*


## State Variables
### VERSION

```solidity
string private constant VERSION = "1.1.0";
```


### dataModuleAppManagerAddress

```solidity
address public immutable dataModuleAppManagerAddress;
```


### newOwner

```solidity
address newOwner;
```


### newDataProviderOwner

```solidity
address newDataProviderOwner;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor(address _dataModuleAppManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataModuleAppManagerAddress`|`address`|address of the owning app manager|


### appAdministratorOrOwnerOnly

*Modifier ensures function caller is a Application Administrators or the parent contract*


```solidity
modifier appAdministratorOrOwnerOnly();
```

### proposeOwner

*This function proposes a new owner that is put in storage to be confirmed in a separate process*


```solidity
function proposeOwner(address _newOwner) external appAdministratorOrOwnerOnly;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|the new address being proposed|


### confirmOwner

*This function confirms a new appManagerAddress that was put in storage. It can only be confirmed by the proposed address*


```solidity
function confirmOwner() external;
```

### confirmDataProvider

*Part of the two step process to set a new Data Provider within a Protocol AppManager*


```solidity
function confirmDataProvider(ProviderType _providerType) external virtual appAdministratorOrOwnerOnly;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_providerType`|`ProviderType`|the type of data provider|


### version

*Get the version of the contract*


```solidity
function version() external pure returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|VERSION|


