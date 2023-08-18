# AppAdministratorOnly
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/32fc908f43bfbb804e52e049074d30ce661a637a/src/economic/AppAdministratorOnly.sol)

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


