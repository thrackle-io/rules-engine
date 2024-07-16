# AppAdministratorOnlyU
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/39d269094241d21cf978e159a9b52cf3c140671a/src/protocol/economic/AppAdministratorOnlyU.sol)

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


