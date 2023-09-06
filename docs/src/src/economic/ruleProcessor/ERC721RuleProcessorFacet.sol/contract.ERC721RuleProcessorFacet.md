# ERC721RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/2e0bd455865a1259ae742cba145517a82fc00f5d/src/economic/ruleProcessor/ERC721RuleProcessorFacet.sol)

**Inherits:**
[IERC721Errors](/src/interfaces/IErrors.sol/interface.IERC721Errors.md), [IRuleProcessorErrors](/src/interfaces/IErrors.sol/interface.IRuleProcessorErrors.md), [IMaxTagLimitError](/src/interfaces/IErrors.sol/interface.IMaxTagLimitError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements NFT Rule checks for rules

*facet in charge of the logic to check non-fungible token rules compliance*


## Functions
### checkNFTTransferCounter

*This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.*


```solidity
function checkNFTTransferCounter(
    uint32 ruleId,
    uint256 transfersWithinPeriod,
    bytes32[] calldata nftTags,
    uint64 lastTransferTime
) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`transfersWithinPeriod`|`uint256`|Number of transfers within the time period|
|`nftTags`|`bytes32[]`|NFT tags|
|`lastTransferTime`|`uint64`|block.timestamp of most recent transaction from sender.|


### checkNFTHoldTime

*This function receives data needed to check Minimum hold time rule. This a simple rule and thus is not stored in the rule storage diamond.*


```solidity
function checkNFTHoldTime(uint32 _holdHours, uint256 _ownershipTs) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_holdHours`|`uint32`|minimum number of hours the asset must be held|
|`_ownershipTs`|`uint256`|beginning of hold period|


