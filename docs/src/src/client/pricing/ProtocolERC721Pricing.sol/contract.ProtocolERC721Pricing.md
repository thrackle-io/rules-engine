# ProtocolERC721Pricing
[Git Source](https://github.com/thrackle-io/tron/blob/9006c7893599df6faee125cfb638dc80c156ce12/src/client/pricing/ProtocolERC721Pricing.sol)

**Inherits:**
Ownable, [IApplicationEvents](/src/common/IEvents.sol/interface.IApplicationEvents.md), [IProtocolERC721Pricing](/src/common/IProtocolERC721Pricing.sol/interface.IProtocolERC721Pricing.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is a simple pricing mechanism only. Its main purpose is to store prices.

*This contract allows for setting prices on entire collections or by tokenId*


## State Variables
### VERSION

```solidity
string private constant VERSION = "1.1.0";
```


### nftPrice

```solidity
mapping(address => mapping(uint256 => uint256)) public nftPrice;
```


### collectionPrice

```solidity
mapping(address => uint256) public collectionPrice;
```


## Functions
### setSingleNFTPrice

*set the price for a single NFT from a collection*


```solidity
function setSingleNFTPrice(address nftContract, uint256 id, uint256 price) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nftContract`|`address`|is the address of the NFT contract|
|`id`|`uint256`|of the NFT|
|`price`|`uint256`|price of the Token in weis of dollars. 10^18 => $ 1.00 USD 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000|


### setNFTCollectionPrice

*set the price for whole collection. If an NFT has a price
specific for it, the collection price would have the second priority.*


```solidity
function setNFTCollectionPrice(address nftContract, uint256 price) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nftContract`|`address`|is the address of the NFT contract|
|`price`|`uint256`|price of the Token in weis of dollars. 10^18 => $ 1.00 USD 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000|


### getNFTPrice

*gets the price of an NFT. It will return the NFT's specific price, or the
price of the collection if no specific price has been given*


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
|`price`|`uint256`|of the Token in weis of dollars. 10^18 => $ 1.00 USD 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000|


### getNFTCollectionPrice

*gets the price of an NFT Collection. It will return the NFT Collection price to be used for each token Id (i.e. Floor Price).*


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
|`price`|`uint256`|for the collection in weis of dollars. 10^18 => $ 1.00 USD 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000|


### version

*gets the version of the contract*


```solidity
function version() external pure returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|VERSION|


