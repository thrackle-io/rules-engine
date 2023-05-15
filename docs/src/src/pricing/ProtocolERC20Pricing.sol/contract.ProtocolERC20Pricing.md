# ProtocolERC20Pricing
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/pricing/ProtocolERC20Pricing.sol)

**Inherits:**
Ownable, [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is a simple pricing mechanism only. Its main purpose is to store prices.

*This contract doesn't allow any marketplace operations.*


## State Variables
### tokenPrices

```solidity
mapping(address => uint256) public tokenPrices;
```


## Functions
### setSingleTokenPrice

that the token is the whole token and not its atomic unit. This means that if an
ERC20 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000

*set the price for a single Token*


```solidity
function setSingleTokenPrice(address tokenContract, uint256 price) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenContract`|`address`|is the address of the Token contract|
|`price`|`uint256`|price of the Token in weis of dollars. 10^18 => $ 1.00 USD|


### getTokenPrice

that the price is for the whole token and not of its atomic unit. This means that if
an ERC20 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000

*gets the price of a Token. It will return the Token's specific price.*


```solidity
function getTokenPrice(address tokenContract) external view returns (uint256 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenContract`|`address`|is the address of the Token contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|of the Token in weis of dollars. 10^18 => $ 1.00 USD|


