# DiamondCutFacet
[Git Source](https://github.com/thrackle-io/Tron/blob/f21da0ad677b5be62ff423760b9c2ce71a2b1c3b/src/diamond/core/DiamondCut/DiamondCutFacet.sol)

**Inherits:**
[IDiamondCut](/src/diamond/core/DiamondCut/IDiamondCut.sol/interface.IDiamondCut.md), [ERC173](/src/diamond/implementations/ERC173/ERC173.sol/abstract.ERC173.md)

\
Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/*****************************************************************************


## Functions
### diamondCut

Add/replace/remove any number of functions and optionally execute
a function with delegatecall


```solidity
function diamondCut(FacetCut[] calldata _diamondCut, address init, bytes calldata data) external override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_diamondCut`|`FacetCut[]`|Contains the facet addresses and function selectors|
|`init`|`address`|The address of the contract or facet to execute "data"|
|`data`|`bytes`|A function call, including function selector and arguments calldata is executed with delegatecall on "init"|


