# AppAdministratorOnly
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/economic/AppAdministratorOnly.sol)

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

