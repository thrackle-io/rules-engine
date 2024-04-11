# IProtocolERC20Pricing
[Git Source](https://github.com/thrackle-io/tron/blob/22d59d8913fec75ff35111960d6c2b98915a9f8b/src/common/IProtocolERC20Pricing.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is a simple pricing mechanism only. Its main purpose is to store prices.

*This contract doesn't allow any marketplace operations.*


## Functions
### getTokenPrice

*Gets the price of a Token. It will return the Token's specific price.*


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


