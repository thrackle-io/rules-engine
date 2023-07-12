# AppAdministratorOrOwnerOnly
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/2eb992c5f8a67ecb6f7fb3675bc386aaa483c728/src/economic/AppAdministratorOrOwnerOnly.sol)

**Inherits:**
Ownable, [IAppAdministratorOnlyErrors](/src/interfaces/IErrors.sol/interface.IAppAdministratorOnlyErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract performs permission controls where admin or owner permissions are required.

*Allows for proper permissioning parent/child contract relationships so that owner and app admins may have permission.*


## Functions
### appAdministratorOrOwnerOnly

*Modifier ensures function caller is a Application Administrators or the parent contract*


```solidity
modifier appAdministratorOrOwnerOnly(address _permissionModuleAppManagerAddress);
```

### _appAdministratorOrOwnerOnly


```solidity
function _appAdministratorOrOwnerOnly(address _permissionModuleAppManagerAddress) private view;
```

### transferPermissionOwnership

*Transfers ownership of the contract to a new account (`newOwner`).*


```solidity
function transferPermissionOwnership(address newOwner, address appManagerAddress) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOwner`|`address`|The address to receive ownership|
|`appManagerAddress`|`address`|address of the app manager for permission check Can only be called by the current owner.|


