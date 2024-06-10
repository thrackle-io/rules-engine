# RuleProcessorDiamond
[Git Source](https://github.com/thrackle-io/tron/blob/e7ccb5e31cec6bae24fd2e457f70702e05f2d4b6/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

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

