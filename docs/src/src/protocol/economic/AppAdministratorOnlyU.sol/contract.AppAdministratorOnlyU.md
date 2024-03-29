# AppAdministratorOnlyU
[Git Source](https://github.com/thrackle-io/tron/blob/35220e3468902ae927d760ed6963ae4507446c20/src/protocol/economic/AppAdministratorOnlyU.sol)

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


