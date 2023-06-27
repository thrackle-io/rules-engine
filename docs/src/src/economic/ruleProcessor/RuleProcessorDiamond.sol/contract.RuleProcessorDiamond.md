# RuleProcessorDiamond
[Git Source](https://github.com/thrackle-io/Tron/blob/89e7f7b48d79c8e2bc6476fb1601cc9680f2c384/src/economic/ruleProcessor/RuleProcessorDiamond.sol)

**Inherits:**
ERC173Facet

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

