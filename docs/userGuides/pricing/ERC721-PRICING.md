# Overview

This is a protocol template for an ERC721-pricing contract. Any custom-made pricing contract that intends to be protocol compliant must implement the [IProtocolERC721Pricing](../../../src/common/IProtocolERC721Pricing.sol) interface, and follow the [price format](./README.md) guideline.

[This template](../../../src/client/pricing/ProtocolERC721Pricing.sol) is available for developers to quickly get their pricing modules up and running.

ERC721 Pricing structure requires that ERC721 contracts support ERC165 interface. 

# Deployment

Refer to the deployment document [here](./DEPLOY-PRICING.md).

# Public Functions

## The price-setter function for a single NFT:

This function should be used in the case of specifying the price for a particular NFT in a collection. This price will prevail over the collection price if any:

### Parameters:
- **nftContract (address)**: the address for the token contract.
- **id (uint256)**: the token Id to set the price for.
- **price (uint256)**: the price in wei of dollars for a whole token (see [example](./README.md)).

```c
function setSingleNFTPrice(address nftContract, uint256 id, uint256 price) external onlyOwner;
```

Notice that only the owner of the pricing contract can successfully invoke this function.

## The price-setter function for an NFT collection:

This function should be used to set the default price for every NFT in a collection. This price should be used as the floor price since the collection price is always overriden by specific NFT price. In other words, the price for an NFT is only going to be the collection price if the NFT doesn't have a particular price set for it.

### Parameters:
- **nftContract (address)**: the address for the token contract.
- **price (uint256)**: the price in wei of dollars for a whole token (see [example](./README.md)).

```c
function setNFTCollectionPrice(address nftContract, uint256 price) external onlyOwner;
```

Notice that only the owner of the pricing contract can successfully invoke this function.

## The price-getter function:
    
### Parameters:
- **tokenContract (address)**: the address for the token contract.

### Returns:
- **price (uint256)**: the price in wei of dollars for a whole token (see [example](./README.md)).

```c
function getNFTPrice(address nftContract, uint256 id) external view returns (uint256 price);
```

## The version-getter function:
    
### Returns: 

- **version (string)**: the string of the protocol version of this template file.
```c
function version() external pure returns (string memory);
```

# Set an ERC721-Pricing Contract in an Asset Handler 

Use the following function in the [asset handler](../architecture/client/assetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md):

```c
function setNFTPricingAddress(
            address _address
        ) 
        external 
        appAdministratorOrOwnerOnly(appManagerAddress);
```
Notice that only accounts with the appAdministrator role can invoke this function successfully.

### Parameters:

- **_address (address)**: the address of the ERC20 pricing contract.

### Events:

- **Event AD1467_ERC721PricingAddressSet(address indexed _address);**
    - Parameters:
        - _address: the address of the pricing contract.


## NFT Valuation Limit

There are certain rules in the protocol which assess cumulative account balances based on ERC20 and ERC721 ownership and valuations. It is possible that an account might own many thousands of NFT's which could cause an "out of gas" error while processing. To mitigate this possible issue, ProtocolERC721Handler contains a variable, **nftValuationLimit**, which is defaulted to 100. This means that any account that owns more than 100 different NFT's will use the NFT Collection price for each type of NFT collection owned as opposed to getting the unique price per tokenId. This reduces gas impacts for the balance based rule checks. This variable may be set to suit the specific needs of each application and/or token and may only be set by an **Application Administrator**.

### ProtocolERC721Handler nftValuationLimit variable definition

```c
function setNFTValuationLimit(uint16 _newNFTValuationLimit) public appAdministratorOrOwnerOnly(appManagerAddress);
```

#### Parameters:

- **_newNFTValuationLimit (uint16)**: Total number of NFT's before collection price is used.
  
### ProtocolERC721Handler Setter Function

```c
function setNFTValuationLimit(uint16 _newNFTValuationLimit) public appAdministratorOrOwnerOnly(appManagerAddress);
```

### ProtocolERC721Handler Getter Function

```c
function getNFTValuationLimit() external view returns (uint256);
```

### Upgrading: 

To upgrade the pricing contract, ensure your new pricing contract is deployed to the same network your [Application Handler](../architecture/client/application/APPLICATION-HANDLER.md) is deployed to. Next, you will call the function `setNFTPricing` from the Application Handler contract. 

```c
function setNFTPricingAddress(address _address) external ruleAdministratorOnly(appManagerAddress)
```


The set function requires the caller to be a [rule administrator](../permissions/ADMIN-ROLES.md). Each pricing contract must conform to the [IProtocolERC721Pricing](../../../src/common/IProtocolERC721Pricing.sol).