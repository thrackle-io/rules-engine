# RuleProcessorDiamond
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/economic/ruleProcessor/nontagged/RuleProcessorDiamond.sol)

**Inherits:**
[ERC173Facet](/src/diamond/implementations/ERC173/ERC173Facet.sol/contract.ERC173Facet.md)

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


### setRuleDataDiamond

*Function sets the Rule Data Diamond Address*


```solidity
function setRuleDataDiamond(address diamondAddress) external onlyOwner;
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

*Function for empty calldata*


```solidity
receive() external payable;
```

