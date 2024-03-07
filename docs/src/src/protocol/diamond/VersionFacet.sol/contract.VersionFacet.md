# VersionFacet
[Git Source](https://github.com/thrackle-io/tron/blob/d6cc09e8b231cc94d92dd93b6d49fb2728ede233/src/protocol/diamond/VersionFacet.sol)

**Inherits:**
ERC173

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is a facet that should be deployed for any protocol diamond.

*setter and getter functions for Version of a diamond.*


## Functions
### updateVersion

*Function to update the version of the Rule Processor Diamond*


```solidity
function updateVersion(string memory newVersion) external onlyOwner;
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


