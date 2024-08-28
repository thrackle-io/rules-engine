# HandlerVersionFacet
[Git Source](https://github.com/thrackle-io/rules-engine/blob/5dd4d5c11842d5927a5d94b280633ba0762dc45b/src/client/token/handler/diamond/HandlerVersionFacet.sol)

**Inherits:**
[IHandlerDiamondEvents](/src/common/IEvents.sol/interface.IHandlerDiamondEvents.md), [AppAdministratorOrOwnerOnlyDiamondVersion](/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol/contract.AppAdministratorOrOwnerOnlyDiamondVersion.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @VoR0220, @GordonPalmer

This is a facet that should be deployed for any handler diamond to track versions.

*setter and getter functions for Version of a diamond.*


## Functions
### updateVersion

*Function to update the version of the Rule Processor Diamond*


```solidity
function updateVersion(string memory newVersion)
    external
    appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newVersion`|`string`|string of the representation of the version in semantic versioning format: --> "MAJOR.MINOR.PATCH".|


### version

*returns the version of the Rule Processor Diamond.*


```solidity
function version() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|string version.|


