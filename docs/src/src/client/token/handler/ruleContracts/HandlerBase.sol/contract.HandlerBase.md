# HandlerBase
[Git Source](https://github.com/thrackle-io/tron/blob/873b14e2bfb8e3c0ec1e8bf0bb215076bd1e60ce/src/client/token/handler/ruleContracts/HandlerBase.sol)

**Inherits:**
[IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IOwnershipErrors](/src/common/IErrors.sol/interface.IOwnershipErrors.md), [AppAdministratorOrOwnerOnlyDiamondVersion](/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol/contract.AppAdministratorOrOwnerOnlyDiamondVersion.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract contains common variables and functions for all Protocol Asset Handlers


## State Variables
### MAX_ORACLE_RULES

```solidity
uint16 constant MAX_ORACLE_RULES = 10;
```


## Functions
### proposeAppManagerAddress

*this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process*


```solidity
function proposeAppManagerAddress(address _newAppManagerAddress)
    external
    appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newAppManagerAddress`|`address`|the new address being proposed|


### confirmAppManagerAddress

*this function confirms a new appManagerAddress that was put in storage. It can only be confirmed by the proposed address*


```solidity
function confirmAppManagerAddress() external;
```

### setLastPossibleAction

*Set the last possible action for use in action validations.*


```solidity
function setLastPossibleAction(uint8 _lastPossibleAction)
    external
    appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_lastPossibleAction`|`uint8`|the highest number in the Action Enum|


