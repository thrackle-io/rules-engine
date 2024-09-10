# AppAdministratorOrOwnerOnlyDiamondVersion
[Git Source](https://github.com/thrackle-io/rules-engine/blob/3a9da30daa774fa67b31c000e53f0c753deac1be/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol)

**Inherits:**
ERC173, [RBACModifiersCommonImports](/src/client/token/handler/common/RBACModifiersCommonImports.sol/abstract.RBACModifiersCommonImports.md), [FacetUtils](/src/client/token/handler/common/FacetUtils.sol/contract.FacetUtils.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract relies on an ERC173 facet already deployed in the diamond.

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


