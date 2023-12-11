# ProtocolAMMCalcCP
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/ProtocolAMMCalcCP.sol)

**Inherits:**
[IProtocolAMMFactoryCalculator](/src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol/abstract.IProtocolAMMFactoryCalculator.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contains the calculations for AMM swap.

*This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
as needed. It contains an example Constant Product xy = k. It is built through ProtocolAMMCalculationFactory*


## Functions
### constructor

*Set up the calculator and appManager for permissions*


```solidity
constructor(address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|appManager address|


### calculateSwap

*This performs the swap from token0 to token1.*


```solidity
function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    external
    pure
    override
    returns (uint256);
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
|`<none>`|`uint256`|_amountOut amount of alternate coming out of the pool|


### simulateSwap

*This performs the swap from token0 to token1.*


```solidity
function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    public
    pure
    override
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|total amount of token0 in reserve|
|`_reserve1`|`uint256`|total amount of token1 in reserve|
|`_amount0`|`uint256`|amount coming to the pool of token0|
|`_amount1`|`uint256`|amount coming to the pool of token1|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price|


