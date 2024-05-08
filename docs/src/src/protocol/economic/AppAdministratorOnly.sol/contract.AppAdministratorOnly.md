# AppAdministratorOnly
[Git Source](https://github.com/thrackle-io/tron/blob/0336bb34620bb9e55e13cd371f0aebd8997d21c3/src/protocol/economic/AppAdministratorOnly.sol)

**Inherits:**
[RBACModifiersCommonImports](/src/client/token/handler/common/RBACModifiersCommonImports.sol/abstract.RBACModifiersCommonImports.md)

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


