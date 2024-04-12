# VersionFacetLib
[Git Source](https://github.com/thrackle-io/tron/blob/898ac13e9c0d669d38da44f8bf60a26e9528ba9b/src/protocol/diamond/VersionFacetLib.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

*the library that handles the storage for the Version facet*


## State Variables
### VERSION_DATA_POSITION

```solidity
bytes32 constant VERSION_DATA_POSITION = keccak256("protocol-version");
```


## Functions
### versionStorage

*Function to access the version data*


```solidity
function versionStorage() internal pure returns (VersionStorage storage v);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`v`|`VersionStorage`|Data storage for version|


