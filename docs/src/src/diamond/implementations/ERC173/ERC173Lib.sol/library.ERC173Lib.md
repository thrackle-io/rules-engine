# ERC173Lib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/diamond/implementations/ERC173/ERC173Lib.sol)


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


