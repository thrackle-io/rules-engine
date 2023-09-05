# ApplicationAMMCalcLinear
[Git Source](https://github.com/thrackle-io/tron/blob/2e0bd455865a1259ae742cba145517a82fc00f5d/src/example/liquidity/ApplicationAMMCalcLinear.sol)

**Inherits:**
[IProtocolAMMCalculator](/src/liquidity/IProtocolAMMCalculator.sol/interface.IProtocolAMMCalculator.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contains the calculations for AMM swap.

*This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
as needed. It contains an example linear. 1 for 1*


## Functions
### calculateSwap

*This performs the swap from token0 to token1. It is a linear calculation.*


```solidity
function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    external
    pure
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|amount of token0 being swapped for unknown amount of token1|
|`_reserve1`|`uint256`|amount of token1 coming out of the pool|
|`_amount0`|`uint256`|amount of token1 coming out of the pool|
|`_amount1`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|_amountOut|


