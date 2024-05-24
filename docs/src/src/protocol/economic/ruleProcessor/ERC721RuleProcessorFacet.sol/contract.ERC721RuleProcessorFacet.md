# ERC721RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/8134a3beedf036c43fc49cdc1818732eb057f270/src/protocol/economic/ruleProcessor/ERC721RuleProcessorFacet.sol)

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
function checkTokenMinHoldTime(uint32 _holdHours, uint256 _ownershipTs) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_holdHours`|`uint32`|minimum number of hours the asset must be held|
|`_ownershipTs`|`uint256`|beginning of hold period|


