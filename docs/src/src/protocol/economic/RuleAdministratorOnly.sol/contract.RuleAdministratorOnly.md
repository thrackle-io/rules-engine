# RuleAdministratorOnly
[Git Source](https://github.com/thrackle-io/tron/blob/ad4d24a5f2b61a5f8e2561806bd722c0cc64e81a/src/protocol/economic/RuleAdministratorOnly.sol)

**Inherits:**
[RBACModifiersCommonImports](/src/client/token/handler/common/RBACModifiersCommonImports.sol/abstract.RBACModifiersCommonImports.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*ruleAdministratorOnly modifier encapsulated for easy imports.*


## Functions
### ruleAdministratorOnly

*Modifier ensures function caller is a App Admin*


```solidity
modifier ruleAdministratorOnly(address _appManagerAddr);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|


