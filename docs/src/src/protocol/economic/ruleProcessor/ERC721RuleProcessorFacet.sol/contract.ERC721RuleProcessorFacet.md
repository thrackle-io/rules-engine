# ERC721RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-engine/blob/459b520a7107e726ba8e04fbad518d00575c4ce1/src/protocol/economic/ruleProcessor/ERC721RuleProcessorFacet.sol)

**Inherits:**
[IERC721Errors](/src/common/IErrors.sol/interface.IERC721Errors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IMaxTagLimitError](/src/common/IErrors.sol/interface.IMaxTagLimitError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements NFT Rule checks

*Facet in charge of the logic to check non-fungible token rules compliance*


## Functions
### checkTokenMinHoldTime

*This function receives data needed to check token min hold time rule. This a simple rule and thus is not stored in the rule storage diamond.*


```solidity
function checkTokenMinHoldTime(uint32 _ruleId, uint256 _ownershipTs) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|ruleId of the rule to check|
|`_ownershipTs`|`uint256`|beginning of hold period|


### getTokenMinHoldTime

*Function to get Token Min Tx Size rules by index*


```solidity
function getTokenMinHoldTime(uint32 _index) public view returns (NonTaggedRules.TokenMinHoldTime memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenMinHoldTime`|Rule at index|


### getTotalTokenMinHoldTime


```solidity
function getTotalTokenMinHoldTime() public view returns (uint32);
```

