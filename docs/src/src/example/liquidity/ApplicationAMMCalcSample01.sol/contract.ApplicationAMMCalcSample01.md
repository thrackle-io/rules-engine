# ApplicationAMMCalcSample01
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/example/liquidity/ApplicationAMMCalcSample01.sol)

**Inherits:**
[IProtocolAMMCalculator](/src/liquidity/IProtocolAMMCalculator.sol/interface.IProtocolAMMCalculator.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contains the calculations for AMM swap.

*This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
as needed. It contains an example NT Algorithm
f = func([0, 10], lambda x: ((10 - x)**2)/2, [0, 50], lambda y: 10 - (2*y)**(.5), tracker = 8)
g = func([0,100], lambda y: 10 - y**(.5), [0,10], lambda x: (10 - x)**2), tracker = 4
Note: These functions have been scaled to work only with ERC20s that have Decimals = 18*


## State Variables
### f_tracker

```solidity
int256 f_tracker = 8 * 10 ** 18;
```


### g_tracker

```solidity
int256 g_tracker = 4 * 10 ** 18;
```


## Functions
### calculateSwap

*This is the overall swap function. It branches to the necessary swap subfunction
x = _reserve0
y = _reserve1
a = _amount0
b = _amount1
k = _reserve0 * _reserve1*


```solidity
function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    external
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


### calculate1for0

Perform the calculations for trading token1 for token0


```solidity
function calculate1for0(uint256 _reserve0, uint256 _amount1) private returns (uint256 _amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|total amount of token0 in reserve|
|`_amount1`|`uint256`|amount of token1 possibly coming into the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amountOut`|`uint256`|amount of alternate coming out of the pool|


### calculate0for1

Perform the calculations for trading token0 for token1


```solidity
function calculate0for1(uint256 _reserve1, uint256 _amount0) private returns (uint256 _amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve1`|`uint256`|total amount of token1 in reserve|
|`_amount0`|`uint256`|amount of token1 possibly coming into the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amountOut`|`uint256`|amount of alternate coming out of the pool|


### sqrt

*This function calculates the square root using uniswap style logic*


```solidity
function sqrt(uint256 y) internal pure returns (uint256 z);
```

## Errors
### AmountsAreZero

```solidity
error AmountsAreZero();
```

### InsufficientPoolDepth

```solidity
error InsufficientPoolDepth(uint256 pool, int256 attemptedWithdrawal);
```

