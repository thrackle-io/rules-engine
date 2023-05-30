# IProtocolERC721Pricing
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/49ab19f6a1a98efed1de2dc532ff3da9b445a7cb/src/pricing/IProtocolERC721Pricing.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is a simple pricing mechanism only. Its main purpose is to store prices.

*This interface is used for simplicity in implementation of actual pricing module.*


## Functions
### getNFTPrice

*gets the price fot an NFT. It will return the NFT's specific price, or the
price of the collection if no specific price hsa been given*


```solidity
function getNFTPrice(address nftContract, uint256 id) external view returns (uint256 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nftContract`|`address`|is the address of the NFT contract|
|`id`|`uint256`|of the NFT|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|of the NFT in cents of dollars. 1000 => $ 10.00 USD|


