# VersionFacetLib
[Git Source](https://github.com/thrackle-io/tron/blob/13105ed31bc78c8d50cdf97173deb83a68e88dee/src/protocol/diamond/VersionFacetLib.sol)

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


