# ProtocolTokenCommonU
[Git Source](https://github.com/thrackle-io/tron/blob/2e0bd455865a1259ae742cba145517a82fc00f5d/src/token/ProtocolTokenCommonU.sol)

**Inherits:**
[AppAdministratorOnlyU](/src/economic/AppAdministratorOnlyU.sol/contract.AppAdministratorOnlyU.md), [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md), [IZeroAddressError](/src/interfaces/IErrors.sol/interface.IZeroAddressError.md), [IOwnershipErrors](/src/interfaces/IErrors.sol/interface.IOwnershipErrors.md)

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

*this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process*


```solidity
function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newAppManagerAddress`|`address`|the new address being proposed|


### confirmAppManagerAddress

*this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address*


```solidity
function confirmAppManagerAddress() external;
```

### getAppManagerAddress

*Function to get the appManagerAddress*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function getAppManagerAddress() external view returns (address);
```

