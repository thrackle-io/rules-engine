# ERC721RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/Tron/blob/fff6da56c1f6c87c36b2aaf57f491c1f4da3b2b2/src/economic/ruleProcessor/nontagged/ERC721RuleProcessorFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements NFT Rule checks for rules

*facet in charge of the logic to check non-fungible token rules compliance*


## Functions
### minAccountBalanceERC721

*Check if transaction passes minAccountBalanceERC721 rule*


```solidity
function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] calldata tokenId, uint256 amount, uint32 ruleId)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|Number of tokens held by sender address|
|`tokenId`|`bytes32[]`|Token ID being transferred|
|`amount`|`uint256`|Number of tokens being transferred|
|`ruleId`|`uint32`|Rule identifier for rule arguments|


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

