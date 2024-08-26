# IProtocolERC721Pricing
[Git Source](https://github.com/thrackle-io/rules-engine/blob/3234c3c6e5bf5f01811a34cd7cc6e00de73aa6c7/src/common/IProtocolERC721Pricing.sol)

**Inherits:**
[NFTPricingErrors](/src/common/IErrors.sol/interface.NFTPricingErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is a simple pricing mechanism only. Its main purpose is to store prices.

*This interface is used for simplicity in implementation of actual pricing module.*


## Functions
### getNFTPrice

*Gets the price for an NFT. It will return the NFT's specific price, or the
price of the collection if no specific price has been given.*


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
|`price`|`uint256`|of the Token in weis of dollars. 10^18 => $ 1.00 USD|


### getNFTCollectionPrice

*Gets the default price for an NFT collection.*


```solidity
function getNFTCollectionPrice(address nftContract) external view returns (uint256 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nftContract`|`address`|is the address of the NFT contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|of the Token in weis of dollars. 10^18 => $ 1.00 USD|


