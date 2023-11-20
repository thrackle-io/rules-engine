# Purpose

The purpose of the pricing contracts is to serve as the token-price data sources for ecosystem applications. The token pricers can be found in 2 different categories:

- [ERC20 pricers](./ERC20-PRICING.md).
- [ERC721 pricers](./ERC721-PRICING.md).

Some protocol rules require these contracts to be set in the tokens for them to be able to work.

# Price Format

- **Price is in weis of US Dollars**: 1 dollar is represented by 1 * 10^18, and 1 cent is represented 1 * 10^16 in these contracts. This is done to have precision over the price, and to account for the possibility of very cheap tokens like the famous Shiba Inu meme token.
- **The price is given for a whole token**:
    - **For Fungible Tokens**: just like regular market data outlets, the price will be given for a whole token (no decimals), the same way the price is given for ETH or BTC, for example, which is not telling the price of a wei of an Ether or a Satoshi of a Bitcoin.
    - **For Non-Fungible-Tokens**: even in the case of a fractionalized NFT, the price is still given for the whole token and not for its freactions.

## Examples:

### ERC20s

Let's say we have the ERC20 called *Thrackle* which has 18 decimals (1 *Thrackle* = 1 * 10^18 weis of a *Thrackle*). Let's imagine that each Thrackle is worth exactly $0.55 US Dollars (55 ¢). In this case, the price for the token will be 55 * 10^16.  

### ERC721s

Let's say we have the NFT collection called *ThrackleNFT*. Let's imagine that the *ThrackleNFT* with Id 222 is worth exactly $500.00 US Dollars. In this case, the price for the token will be 500 * 10^18.  


