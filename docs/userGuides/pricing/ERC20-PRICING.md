# Overview

This is a protocol template for an ERC20-pricing contract. Any custom-made pricing contract that intends to be protocol compliant must implement the [IProtocolERC20Pricing](../../src/pricing/IProtocolERC20Pricing.sol) interface, and follow the [price format](./README.md) guideline.

[This template](../../src/pricing/ProtocolERC20Pricing.sol) is available for developers to quickly get their pricing modules up and running.

# Deployment

Refer to the deployment document [here](../deployment/DEPLOY-PRICING.md).

# Public Functions

## The price-setter function:

### Parameters:
- **tokenContract (address)**: the address for the token contract.
- **price (uint256)**: the price in wei of dollars for a whole token (see [example](./README.md)).

```c
function setSingleTokenPrice(address tokenContract, uint256 price) external onlyOwner;
```

Notice that only the owner of the pricing contract can successfully invoke this function.

## The price-getter function:
    
### Parameters:
- **tokenContract (address)**: the address for the token contract.

### Returns:
- **price (uint256)**: the price in wei of dollars for a whole token (see [example](./README.md)).

```c
function getTokenPrice(address tokenContract) external view returns (uint256 price);
```

## The version-getter function:
    
### Returns: 

- **version (string)**: the string of the protocol version of this template file.
```c
function version() external pure returns (string memory);
```

# Set an ERC20-Pricing Contract in an Asset Handler 

Use the following function in the [asset handler](../../src/client/token/ProtocolHandlerCommon.sol):

```c
function setERC20PricingAddress(
            address _address
        ) 
        external 
        appAdministratorOrOwnerOnly(appManagerAddress);
```
Notice that only accounts with the appAdministrator role can invoke this function successfully.

### Parameters:

- **_address (address)**: the address of the ERC20 pricing contract.

### Events:

- **event ERC20PricingAddressSet(address indexed _address);**
    - Parameters:
        - _address: the address of the pricing contract.
