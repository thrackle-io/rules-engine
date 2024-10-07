# VersionFacetLib
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/6da66dae531fe9b9e3ff74f1c472024c95ff4417/src/protocol/diamond/VersionFacetLib.sol)

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


