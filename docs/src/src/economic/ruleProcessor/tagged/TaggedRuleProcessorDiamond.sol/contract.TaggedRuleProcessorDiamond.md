# TaggedRuleProcessorDiamond
[Git Source](https://github.com/thrackle-io/Tron/blob/8687bd810e678d8633ed877521d2c463c1677949/src/economic/ruleProcessor/nontagged/TaggedRuleProcessorDiamond.sol)

**Inherits:**
[ERC173Facet](/src/diamond/implementations/ERC173/ERC173Facet.sol/contract.ERC173Facet.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Diamond for Tagged Rules

*Diamond serves as the address for all Tagged Rules for protocol*


## Functions
### constructor

*constructor creates facets for the diamond at deployment*


```solidity
constructor(FacetCut[] memory diamondCut, TaggedRuleProcessorDiamondArgs memory args) payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`diamondCut`|`FacetCut[]`|Array of Facets to be created at deployment|
|`args`|`TaggedRuleProcessorDiamondArgs`|Arguments for the Facets Position and Addresses|


### setRuleDataDiamond

*Function sets the Rule Data Diamond Address*


```solidity
function setRuleDataDiamond(address diamondAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`diamondAddress`|`address`|Address of the Rule Data Diamond|


### getRuleDataDiamondAddress

*Function retrieves Rule Data Diamond*


```solidity
function getRuleDataDiamondAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|taggedRules Address of the Rule Data Diamond|


### fallback

*Function finds facet for function that is called and execute the function if a facet is found and return any value.*


```solidity
fallback() external payable;
```

### receive

get facet from function selector
copy function selector and any arguments
execute function call using the facet
get any return value
return any return value or error back to the caller

*Function for empty calldata*


```solidity
receive() external payable;
```

