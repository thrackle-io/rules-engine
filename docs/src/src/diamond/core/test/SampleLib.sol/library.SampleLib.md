# SampleLib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4e5c0bf97c314267dd6acccac5053bfaa6859607/src/diamond/core/test/SampleLib.sol)


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

