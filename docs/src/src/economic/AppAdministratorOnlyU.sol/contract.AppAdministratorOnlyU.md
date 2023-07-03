# AppAdministratorOnlyU
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/9adfea3f253340fbb4af30cdc0009d491b72e160/src/economic/AppAdministratorOnlyU.sol)

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

