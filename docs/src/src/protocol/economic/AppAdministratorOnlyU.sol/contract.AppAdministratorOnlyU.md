# AppAdministratorOnlyU
[Git Source](https://github.com/thrackle-io/rules-engine/blob/5dd4d5c11842d5927a5d94b280633ba0762dc45b/src/protocol/economic/AppAdministratorOnlyU.sol)

**Inherits:**
ContextUpgradeable, [IPermissionModifierErrors](/src/common/IErrors.sol/interface.IPermissionModifierErrors.md)

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


