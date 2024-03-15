# AppAdministratorOrOwnerOnly
[Git Source](https://github.com/thrackle-io/tron/blob/4674814db01d3b90ed90d394187432e47d662f5c/src/protocol/economic/AppAdministratorOrOwnerOnly.sol)

**Inherits:**
Ownable, [RBACModifiersCommonImports](/src/client/token/handler/common/RBACModifiersCommonImports.sol/abstract.RBACModifiersCommonImports.md)

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


