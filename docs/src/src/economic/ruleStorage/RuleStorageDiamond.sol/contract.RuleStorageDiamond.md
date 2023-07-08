# RuleStorageDiamond
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/1ab1db06d001c0ea3265ec49b85ddd9394430302/src/economic/ruleStorage/RuleStorageDiamond.sol)

**Inherits:**
[IRuleStorageDiamondEvents](/src/interfaces/IEvents.sol/interface.IRuleStorageDiamondEvents.md)

**Author:**
@oscarsernarosero, built on top of Nick Mudge implementation.

*main contract of the Rule diamond pattern. Mainly responsible
for storing the diamnond-pattern logic and binding together the different facets.*


## Functions
### constructor

*constructor creates facets for the diamond at deployment*


```solidity
constructor(FacetCut[] memory diamondCut, RuleStorageDiamondArgs memory args) payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`diamondCut`|`FacetCut[]`|Array of Facets to be created at deployment|
|`args`|`RuleStorageDiamondArgs`|Arguments for the Facets Position and Addresses|


### fallback

*Function finds facet for function that is called and execute the function if a facet is found and return any value.*


```solidity
fallback() external payable;
```

### receive

get facet from function selector
copy function selector and any arguments
execute function call using the facet
return any return value or error back to the caller

*Function for empty calldata*


```solidity
receive() external payable;
```

