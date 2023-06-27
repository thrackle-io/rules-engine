# AppAdministratorOnlyU
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/121468a758a67e73dd1df571fd4e956242c3c973/src/economic/AppAdministratorOnlyU.sol)

**Inherits:**
ContextUpgradeable

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

