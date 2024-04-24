# RuleAdministratorOnly
[Git Source](https://github.com/thrackle-io/tron/blob/fd00dd3f701afe5991226ded04be9da490ad380d/src/protocol/economic/RuleAdministratorOnly.sol)

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


