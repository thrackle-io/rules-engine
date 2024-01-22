# PRICING CONTRACTS

## Purpose

The purpose of the pricing contracts is to serve as token-price data sources for ecosystem applications. The token pricers can be found in 2 different categories:

- [ERC20 pricers](./ERC20-PRICING.md).
- [ERC721 pricers](./ERC721-PRICING.md).

Developers may choose to adapt their preferred third-party solution for token pricing:

- [Third-party solutions](./THIRD-PARTY-SOLUTIONS.md).

Configured pricing modules are required for the following rules:

- [Account Balance by Risk](../rules/ACCOUNT-BALANCE-BY-RISK.md).
- [Max Balance by Access Level](../rules/MAX-BALANCE-BY-ACCESS-LEVEL.md).
- [Tx Size per Period by Risk Score](../rules/TX-SIZE-PER-PERIOD-BY-RISK-SCORE.md).

## Configuration

To set up the pricer contracts:

1. Make sure you have deployed your [ERC20](./ERC20-PRICING.md) and your [ERC721](./ERC721-PRICING.md) pricer contracts, or that your [third party solutions](./THIRD-PARTY-SOLUTIONS.md) are ready to communicate with your application.

2. Connect the pricer-contract set to your appManager. For this, only an account with the role of ruleAdministrator will be able to call the following functions in the appManager Handler:

```c
/**
     * @dev sets the address of the erc20 pricing contract and loads the contract.
     * @param _address ERC20 Pricing Contract address.
     */
    function setERC20PricingAddress(address _address) external ruleAdministratorOnly(appManagerAddress);

    /**
     * @dev sets the address of the nft pricing contract and loads the contract.
     * @param _address Nft Pricing Contract address.
     */
    function setNFTPricingAddress(address _address) external ruleAdministratorOnly(appManagerAddress);
```

Pass the addresses for your pricer contracts respectively, and you're done!

### Example

- Cast command example to set the ERC20 pricer contract:

    ```
    cast send $APPLICATION_HANDLER "setERC20PricingAddress(address)()" $APPLICATION_ERC20_PRICER --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ```

- Cast command example to set the ERC721 pricer contract:

    ```
    cast send $APPLICATION_HANDLER "setNFTPricingAddress(address)()" $APPLICATION_ERC721_PRICER --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ```

This set of contracts can be reset at any time by an ruleAdministrator. Simply follow the same steps mentioned above with the new addresses.

## Price Format

- **Price is in wei of US Dollars**: 1 dollar is represented by 1 * 10^18, and 1 cent is represented 1 * 10^16 in these contracts. This is done to have precision over the price, and to account for the possibility of tokens with extremely low prices.
- **The price is given for a whole token**:
    - **For Fungible Tokens**: just like regular market data outlets, the price will be given for a whole token without decimals. e.g 1 ETH.
    - **For Non-Fungible-Tokens**: even in the case of a fractionalized NFT, the price is still given for the whole token and not for its fractions.

### Examples:

#### ERC20s

Let's say we have the ERC20 called *Frankenstein* which has 18 decimals (1 *Frankenstein* = 1 * 10^18 wei of a *Frankenstein*). Let's imagine that each *Frankenstein* is worth exactly $0.55 US Dollars (55 ¢). In this case, the price for the token will be 55 * 10^16.  

#### ERC721s

Let's say we have the NFT collection called *FrankensteinNFT*. Let's imagine that the *FrankensteinNFT* with Id 222 is worth exactly $500.00 US Dollars. In this case, the price for the token will be 500 * 10^18.  


