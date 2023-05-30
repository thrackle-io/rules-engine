# ERC165Lib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4f7789968960e18493ff0b85b09856f12969daac/src/diamond/implementations/ERC165/ERC165Lib.sol)


## State Variables
### ERC165_STORAGE_POSITION

```solidity
bytes32 constant ERC165_STORAGE_POSITION = keccak256("erc165.storage");
```


## Functions
### s

Return the storage struct for reading and writing.


```solidity
function s() internal pure returns (ERC165Storage storage storageStruct);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`storageStruct`|`ERC165Storage`|The ERC165 storage struct.|


### setSupportedInterface

Set or unset a supported interface.


```solidity
function setSupportedInterface(bytes4 interfaceId, bool status) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface id to set or unset.|
|`status`|`bool`|Wheter to add or remove the interface support.|


