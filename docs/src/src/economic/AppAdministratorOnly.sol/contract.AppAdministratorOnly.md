# AppAdministratorOnly
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/economic/AppAdministratorOnly.sol)

**Inherits:**
Context, [IPermissionModifierErrors](/src/interfaces/IErrors.sol/interface.IPermissionModifierErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*appAdministratorOnly modifier encapsulated for easy imports.*


## Functions
### appAdministratorOnly

*Modifier ensures function caller is a App Admin*


```solidity
modifier appAdministratorOnly(address _appManagerAddr);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|


