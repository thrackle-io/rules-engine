# CustomERC721Pricing
[Git Source](https://github.com/thrackle-io/tron/blob/1e4e061752cea9c86408a9ccfc7ebc0d0de4bb9a/src/example/pricing/CustomERC721Pricing.sol)

**Inherits:**
Ownable, [IApplicationEvents](/src/common/IEvents.sol/interface.IApplicationEvents.md), [IProtocolERC721Pricing](/src/common/IProtocolERC721Pricing.sol/interface.IProtocolERC721Pricing.md), [AppAdministratorOnly](/src/protocol/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is an example of how one could implement a custom pricing solution. It uses a Chainlink Price Feed to get the token price


## State Variables
### pudgyPenguin

```solidity
address private pudgyPenguin = 0xBd3531dA5CF5857e7CfAA92426877b022e612cf8;
```


### pudgyPenguinFeed

```solidity
address private pudgyPenguinFeed = 0x9f2ba149c2A0Ee76043d83558C4E79E9F3E5731B;
```


### cryptoPunk

```solidity
address private cryptoPunk = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
```


### cryptoPunkFeed

```solidity
address private cryptoPunkFeed = 0x01B6710B01cF3dd8Ae64243097d91aFb03728Fdd;
```


### azuki

```solidity
address private azuki = 0xED5AF388653567Af2F388E6224dC7C4b3241C544;
```


### azukiFeed

```solidity
address private azukiFeed = 0xA8B9A447C73191744D5B79BcE864F343455E1150;
```


### appManagerAddress

```solidity
address private immutable appManagerAddress;
```


## Functions
### constructor


```solidity
constructor(address _appManagerAddress);
```

### getNFTPrice

that the price is for the whole token and not of its atomic unit. This means that if
an ERC721 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000

*Gets the price of an NFT. It will return the Token's specific price. This function is left here to preserve the function signature. NOTE: This is  * only the floor price at the contract level. As of create date, Chainlink does not have a tokenId based pricing solution.*


```solidity
function getNFTPrice(address nftContract, uint256 id) external view returns (uint256 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nftContract`|`address`|is the address of the NFT contract|
|`id`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|of the Token in weis of dollars. 10^18 => $ 1.00 USD|


### getNFTCollectionPrice

Chainlink only provides floor price feeds, so this function mirrors getNFTPrice() in functionality.
The price is for the whole token and not of its atomic unit. This means that if
an ERC721 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000

*Gets the price of an NFT. It will return the Token's specific price. This function is left here to preserve the function signature. NOTE: This is  * only the floor price at the contract level. As of create date, Chainlink does not have a tokenId based pricing solution.*


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


### getChainlinkPudgyToUSDFeedPrice

*Gets the Chainlink floor price feed for PudgyPenguins in USD. This is an example that works for any decimal denomination.*


```solidity
function getChainlinkPudgyToUSDFeedPrice() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|floorPrice The floor price in USD for this collection according to Chainlink aggregation|


### getChainlinkCryptoToUSDFeedPrice

*Gets the Chainlink floor price feed for Cryptopunks in USD. This is an example that works for any decimal denomination.*


```solidity
function getChainlinkCryptoToUSDFeedPrice() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|floorPrice The floor price in USD for this collection according to Chainlink aggregation|


### getChainlinkAzukiToUSDFeedPrice

*Gets the Chainlink floor price feed for Azuki in USD. This is an example that works for any decimal denomination.*


```solidity
function getChainlinkAzukiToUSDFeedPrice() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|floorPrice The floor price in USD for this collection according to Chainlink aggregation|


### setCryptoPunkAddress

*This function allows appAdminstrators to set the token address*


```solidity
function setCryptoPunkAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setCryptoPunkFeedAddress

*This function allows appAdminstrators to set the Chainlink price feed address*


```solidity
function setCryptoPunkFeedAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setAzukiAddress

*This function allows appAdminstrators to set the token address*


```solidity
function setAzukiAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setAzuikiFeedAddress

*This function allows appAdminstrators to set the Chainlink price feed address*


```solidity
function setAzuikiFeedAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setPudgyPenguinAddress

*This function allows appAdminstrators to set the token address*


```solidity
function setPudgyPenguinAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setPudgyPenguinFeedAddress

*This function allows appAdminstrators to set the Chainlink price feed address*


```solidity
function setPudgyPenguinFeedAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

## Errors
### NoPriceFeed

```solidity
error NoPriceFeed(address tokenAddress);
```

