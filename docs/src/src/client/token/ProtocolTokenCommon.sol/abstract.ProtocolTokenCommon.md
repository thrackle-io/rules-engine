# ProtocolTokenCommon
[Git Source](https://github.com/thrackle-io/tron/blob/7030db34eb7187742ede73deed40ef4d7dddaa1b/src/client/token/ProtocolTokenCommon.sol)

**Inherits:**
[AppAdministratorOnly](/src/protocol/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IApplicationEvents](/src/common/IEvents.sol/interface.IApplicationEvents.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IOwnershipErrors](/src/common/IErrors.sol/interface.IOwnershipErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract contains common variables and functions for all Protocol Tokens


## State Variables
### newAppManagerAddress

```solidity
address newAppManagerAddress;
```


### appManagerAddress

```solidity
address appManagerAddress;
```


### appManager

```solidity
IAppManager appManager;
```


## Functions
### proposeAppManagerAddress

*This function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process*


```solidity
function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newAppManagerAddress`|`address`|the new address being proposed|


### confirmAppManagerAddress

*This function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address*


```solidity
function confirmAppManagerAddress() external;
```

### getAppManagerAddress

*Function to get the appManagerAddress*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function getAppManagerAddress() external view returns (address);
```

### getHandlerAddress

*This function returns the handler address*


```solidity
function getHandlerAddress() external view virtual returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


