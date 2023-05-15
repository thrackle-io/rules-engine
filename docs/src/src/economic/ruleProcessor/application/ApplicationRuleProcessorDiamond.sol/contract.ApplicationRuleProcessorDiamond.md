# ApplicationRuleProcessorDiamond
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/economic/ruleProcessor/application/ApplicationRuleProcessorDiamond.sol)

**Inherits:**
[ERC173Facet](/src/diamond/implementations/ERC173/ERC173Facet.sol/contract.ERC173Facet.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the entry point for access action checks

*This pattern was adopted from: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen).*


## Functions
### constructor

*Use the facets and arguments to create a new ApplicationHandlerDiamond*


```solidity
constructor(FacetCut[] memory diamondCut, DiamondArgs memory args) payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`diamondCut`|`FacetCut[]`|facet cuts to send through to the diamond cutter|
|`args`|`DiamondArgs`|arguments for diamond cutter|


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

*Find the facet for the function called and execute it if found, then return any value.*


```solidity
fallback() external payable;
```

### receive

get facet from function selector

*Stubbed receive function.*


```solidity
receive() external payable;
```

