# SampleLib
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/diamond/core/test/SampleLib.sol)


## State Variables
### SAMPLE_STORAGE_POSITION

```solidity
bytes32 constant SAMPLE_STORAGE_POSITION = keccak256("sample.storage");
```


## Functions
### s

Return the storage struct for reading and writing.


```solidity
function s() internal pure returns (SampleStorage storage storageStruct);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`storageStruct`|`SampleStorage`|The sample  storage struct.|


### sampleFunction


```solidity
function sampleFunction() internal pure returns (string memory);
```

