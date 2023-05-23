# AppAdministratorOnly
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/economic/AppAdministratorOnly.sol)

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

