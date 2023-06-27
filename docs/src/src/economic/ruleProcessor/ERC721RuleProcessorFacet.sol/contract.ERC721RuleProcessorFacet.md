# ERC721RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/Tron/blob/89e7f7b48d79c8e2bc6476fb1601cc9680f2c384/src/economic/ruleProcessor/ERC721RuleProcessorFacet.sol)

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


## Errors
### MaxNFTTransferReached

```solidity
error MaxNFTTransferReached();
```

### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

