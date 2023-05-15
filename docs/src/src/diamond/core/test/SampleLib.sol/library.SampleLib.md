# SampleLib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/diamond/core/test/SampleLib.sol)


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

