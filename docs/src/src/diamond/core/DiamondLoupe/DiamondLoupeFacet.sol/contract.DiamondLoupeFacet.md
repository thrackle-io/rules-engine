# DiamondLoupeFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4e5c0bf97c314267dd6acccac5053bfaa6859607/src/diamond/core/DiamondLoupe/DiamondLoupeFacet.sol)

**Inherits:**
[IDiamondLoupe](/src/diamond/core/DiamondLoupe/IDiamondLoupe.sol/interface.IDiamondLoupe.md)

\
Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/*****************************************************************************


## Functions
### facets

Gets all facets and their selectors.


```solidity
function facets() external view override returns (Facet[] memory facets_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facets_`|`Facet[]`|Facet|


### facetFunctionSelectors

Gets all the function selectors supported by a specific facet.


```solidity
function facetFunctionSelectors(address _facet)
    external
    view
    override
    returns (bytes4[] memory _facetFunctionSelectors);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facet`|`address`|The facet address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_facetFunctionSelectors`|`bytes4[]`|The selectors associated with a facet address.|


### facetAddresses

Get all the facet addresses used by a diamond.


```solidity
function facetAddresses() external view override returns (address[] memory facetAddresses_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddresses_`|`address[]`|facetAddresses_|


### facetAddress

Gets the facet address that supports the given selector.

*If facet is not found return address(0).*


```solidity
function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_functionSelector`|`bytes4`|The function selector.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddress_`|`address`|The facet address.|


