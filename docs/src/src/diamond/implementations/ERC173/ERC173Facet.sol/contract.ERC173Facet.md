# ERC173Facet
[Git Source](https://github.com/thrackle-io/Tron/blob/f21da0ad677b5be62ff423760b9c2ce71a2b1c3b/src/diamond/implementations/ERC173/ERC173Facet.sol)

**Inherits:**
[IERC173](/src/interfaces/IERC173.sol/interface.IERC173.md), [ERC173](/src/diamond/implementations/ERC173/ERC173.sol/abstract.ERC173.md)


## Functions
### owner

Get the address of the owner


```solidity
function owner() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|owner_ The address of the owner.|


### transferOwnership

Set the address of the new owner of the contract

*Set _newOwner to address(0) to renounce any ownership.*


```solidity
function transferOwnership(address newOwner) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOwner`|`address`||


