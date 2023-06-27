# AppAdministratorOnlyU
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2955538441cd4ad2d51a27d7c28af7eec4cd8814/src/economic/AppAdministratorOnlyU.sol)

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

