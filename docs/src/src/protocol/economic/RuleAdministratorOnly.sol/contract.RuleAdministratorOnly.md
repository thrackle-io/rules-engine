# RuleAdministratorOnly
[Git Source](https://github.com/thrackle-io/tron/blob/d4dc3a1319e6df3195618c1297a6c755d61cf319/src/protocol/economic/RuleAdministratorOnly.sol)

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


