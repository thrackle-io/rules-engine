# IProtocolAMMCalculator
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/liquidity/IProtocolAMMCalculator.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contains the calculations for AMM swap.

*This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
as needed.*


## Functions
### calculateSwap

*This performs the swap from token0 to token1*


```solidity
function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    external
    returns (uint256 _amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|total amount of token0 in reserve|
|`_reserve1`|`uint256`|total amount of token1 in reserve|
|`_amount0`|`uint256`|amount of token0 possibly coming into the pool|
|`_amount1`|`uint256`|amount of token1 possibly coming into the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amountOut`|`uint256`|amount of alternate coming out of the pool|


