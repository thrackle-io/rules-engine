# AppAdministratorOrOwnerOnly
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/32fc908f43bfbb804e52e049074d30ce661a637a/src/economic/AppAdministratorOrOwnerOnly.sol)

**Inherits:**
Ownable, [IPermissionModifierErrors](/src/interfaces/IErrors.sol/interface.IPermissionModifierErrors.md)

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


