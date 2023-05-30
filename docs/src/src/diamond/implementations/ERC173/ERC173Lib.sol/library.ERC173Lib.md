# ERC173Lib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/b3877670eae43a9723081d42c4401502ebd5b9f6/src/diamond/implementations/ERC173/ERC173Lib.sol)


## State Variables
### ERC173_STORAGE_POSITION

```solidity
bytes32 constant ERC173_STORAGE_POSITION = keccak256("erc173.storage");
```


## Functions
### s

Return the storage struct for reading and writing.


```solidity
function s() internal pure returns (ERC173Storage storage storageStruct);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`storageStruct`|`ERC173Storage`|The ERC173 storage struct.|


