# IProtocolERC20Pricing
[Git Source](https://github.com/thrackle-io/Tron/blob/68f4a826ed4aff2c87e6d1264dce053ee793c987/src/pricing/IProtocolERC20Pricing.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is a simple pricing mechanism only. Its main purpose is to store prices.

*This contract doesn't allow any marketplace operations.*


## Functions
### getTokenPrice

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
|`price`|`uint256`|of the Token in cents of dollars. 1000 => $ 10.00 USD|


