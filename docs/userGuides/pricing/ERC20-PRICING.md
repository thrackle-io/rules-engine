# Overview

This is a [protocol template](../../../src/pricing/ProtocolERC20Pricing.sol) for an ERC20-pricing contract. Any custom-made pricing contract that intends to be protocol compliant must implement the [IProtocolERC20PRicing](../../../src/pricing/IProtocolERC20Pricing.sol) interface, and follow the [price format](#Price-Format) guideline.

This template is available for developers to quickly get their pricing modules up and running.

# Deployment

Refer to the deployment document [here](../deployment/DEPLOY-PRICING.md).

# Price Format

- **Price is in weis of US Dollars**: 1 dollar is represented by 1 * 10^18, and 1 cent is represented 1 * 10^16 in these contracts. This is done to have precision over the price, and to account for the possibility of very cheap tokens like the famous Shiba Inu meme token.
- **The price is given for a whole token**:  just like regular market data outlets, the price will be given for a whole token (no decimals), the same way the price is given for ETH or BTC, for example, which is not telling the price of a wei of an Ether or a Satoshi of a Bitcoin.

## Example:

Let's say we have the ERC20 called *Thrackle* which has 18 decimals (1 *Thrackle* = 1 * 10^18 weis of a *Thrackle*). Let's imagine that each Thrackle is worth exactly $0.55 US Dollars (55 ¢). In this case, the price for the token will be 55 * 10^16.  


# Public Functions

-  The price-setter function:

    Parameters:
    - **tokenContract (address)**: the address for the token contract.
    - **price (uint256)**: the price in weis of dollars for a whole token (see [example](##Example)).

    ```c
    function setSingleTokenPrice(address tokenContract, uint256 price) external;
    ```
- The price-getter function:
    
    Parameters:
    - **tokenContract (address)**: the address for the token contract.
    
    Returns:
    - **price (uint256)**: the price in weis of dollars for a whole token (see [example](##Example)).

    ```c
    function getTokenPrice(address tokenContract) external view returns (uint256 price)
    ```

- The version getter function:
    
    Returns: 
    - **version (string)**: the string of the protocol version of this template file.
    ```c
    function version() external pure returns (string memory)
    ```

# Set an Asset to Listen to a Pricing Contract

Use the following function in the asset handler:

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
