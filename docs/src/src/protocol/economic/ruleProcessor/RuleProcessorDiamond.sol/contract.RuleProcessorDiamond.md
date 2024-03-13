# RuleProcessorDiamond
[Git Source](https://github.com/thrackle-io/tron/blob/af28404fa455abf3b77fe8e040ff86d48b926353/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

**Inherits:**
ERC173, [IRuleProcessorDiamondEvents](/src/common/IEvents.sol/interface.IRuleProcessorDiamondEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Contract checks the rules for success

*Main contract of the diamond pattern. Responsible for checking
on rules compliance.*


## Functions
### constructor

*constructor creates facets for the diamond at deployment*


```solidity
constructor(FacetCut[] memory diamondCut, RuleProcessorDiamondArgs memory args) payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`diamondCut`|`FacetCut[]`|Array of Facets to be created at deployment|
|`args`|`RuleProcessorDiamondArgs`|Arguments for the Facets Position and Addresses|


### fallback

*Function finds facet for function that is called and execute the function if a facet is found and return any value.*


```solidity
fallback() external payable;
```

### receive

*Function for empty calldata*


```solidity
receive() external payable;
```

