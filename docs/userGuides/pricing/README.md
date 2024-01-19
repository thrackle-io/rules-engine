# PRICING CONTRACTS

## Purpose

The purpose of the pricing contracts is to serve as token-price data sources for ecosystem applications. The token pricers can be found in 2 different categories:

- [ERC20 pricers](./ERC20-PRICING.md).
- [ERC721 pricers](./ERC721-PRICING.md).

Some protocol rules require these contracts to be set in the tokens for them to be able to work:

- [Account Balance by Risk](../rules/ACCOUNT-BALANCE-BY-RISK.md).
- [Max Balance by Access Level](../rules/MAX-BALANCE-BY-ACCESS-LEVEL.md).
- [Tx Size per Period by Risk Score](../rules/TX-SIZE-PER-PERIOD-BY-RISK-SCORE.md).

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


