# AppAdministratorOnly
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/economic/AppAdministratorOnly.sol)

**Inherits:**
Context

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


## Errors
### AppManagerNotConnected

```solidity
error AppManagerNotConnected();
```

### NotAppAdministrator

```solidity
error NotAppAdministrator();
```

