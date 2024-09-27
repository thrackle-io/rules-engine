# ProtocolTokenCommonU
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/0c70bcd32f4dcc456508b64e73411cac76dd6f09/src/client/token/ProtocolTokenCommonU.sol)

**Inherits:**
[AppAdministratorOnlyU](/src/protocol/economic/AppAdministratorOnlyU.sol/contract.AppAdministratorOnlyU.md), [IProtocolToken](/src/client/token/IProtocolToken.sol/interface.IProtocolToken.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IOwnershipErrors](/src/common/IErrors.sol/interface.IOwnershipErrors.md)

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

