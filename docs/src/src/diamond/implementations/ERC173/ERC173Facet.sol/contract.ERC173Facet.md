# ERC173Facet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/diamond/implementations/ERC173/ERC173Facet.sol)

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


