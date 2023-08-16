# AppAdministratorOnlyU
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/d0344b27291308c442daefb74b46bb81740099e4/src/economic/AppAdministratorOnlyU.sol)

**Inherits:**
ContextUpgradeable, [IPermissionModifierErrors](/src/interfaces/IErrors.sol/interface.IPermissionModifierErrors.md)

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


