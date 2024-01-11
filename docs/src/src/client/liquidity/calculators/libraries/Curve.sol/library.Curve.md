# Curve
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/libraries/Curve.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This library only contains 2 function which are overloaded to accept different curves.
Every curve should has its own implementation of both getY() function and fromInput() function.

*This is a library for AMM Bonding Curves to have their functions in a standarized API.*


## State Variables
### ATTO

```solidity
uint256 constant ATTO = 10 ** 18;
```


## Functions
### getY

~~~~~~~~ LinearWholeB ~~~~~~~~

the original ecuation y = mx + b  is replacing m by m_num/m_den.

*calculates ƒ(x) for linear curve.*


```solidity
function getY(LinearWholeB memory line, uint256 x) internal pure returns (uint256 y);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`line`|`LinearWholeB`|the LinearWholeB curve or function *ƒ*|
|`x`|`uint256`|the scalar on the abscissa axis to calculate *ƒ(x)*.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`y`|`uint256`|the value of ƒ(x) on the ordinate axis in ATTOs|


### integral


```solidity
function integral(LinearWholeB memory line, uint256 x) internal pure returns (uint256 a);
```

### fromInput

a = (((line.m_num * line.m_num) / (line.m_den * line.m_den)) * (x * x) * ATTO) + (line.b * x);

*creates a LinearWholeB curve from a user's LinearInput. This mostly means that m is represented now by m_num/m_den.*


```solidity
function fromInput(LinearWholeB storage line, LinearInput memory input, uint256 precisionDecimals) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`line`|`LinearWholeB`|the LinearWholeB in storage that will be built from the input.|
|`input`|`LinearInput`|the LinearInput entered by the user to be stored.|
|`precisionDecimals`|`uint256`|the amount of precision decimals that the input's slope is formatted with.|


### getY

~~~~~~~~ LinearFractionB ~~~~~~~~

the original ecuation y = mx + b  is replacing m by m_num/m_den.

*calculates ƒ(x) for linear curve.*


```solidity
function getY(LinearFractionB memory line, uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    internal
    pure
    returns (uint256 y);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`line`|`LinearFractionB`|the LinearWholeB curve or function *ƒ*|
|`_reserve0`|`uint256`|reserves of token0|
|`_reserve1`|`uint256`|reserves of token1|
|`_amount0`|`uint256`|the token0s received|
|`_amount1`|`uint256`|the token1s received|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`y`|`uint256`|the value of ƒ(x) on the ordinate axis in ATTOs|


### integral


```solidity
function integral(LinearFractionB memory line, uint256 x) internal pure returns (uint256 a);
```

### fromInput

a = (((line.m_num * line.m_num) / (line.m_den * line.m_den)) * (x * x) * ATTO) + (line.b * x);

*creates a LinearWholeB curve from a user's LinearInput. This mostly means that m and b are represented by fractions.*


```solidity
function fromInput(
    LinearFractionB storage line,
    LinearInput memory input,
    uint256 precisionDecimals_m,
    uint256 precisionDecimals_b
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`line`|`LinearFractionB`|the LinearWholeB in storage that will be built from the input.|
|`input`|`LinearInput`|the LinearInput entered by the user to be stored.|
|`precisionDecimals_m`|`uint256`|the amount of precision decimals that the input's slope is formatted with.|
|`precisionDecimals_b`|`uint256`|the amount of precision decimals that the input's intersection with the Y axis is formatted with.|


### getY

this is different than original. Double check
~~~~~~~~ ConstantRatio ~~~~~~~~

*calculates ƒ(amountIn) for a constant-ratio AMM.*


```solidity
function getY(ConstantRatio memory cr, uint256 _amount0, uint256 _amount1) internal pure returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`cr`|`ConstantRatio`|the values of x and y for the constant ratio.|
|`_amount0`|`uint256`|the token0s received|
|`_amount1`|`uint256`|the token1s received|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|amountOut|


### getY

~~~~~~~~ ConstantProduct ~~~~~~~~

*calculates ƒ(amountIn) for a constant-product AMM.
Based on (x + a) * (y - b) = x * y
This is sometimes simplified as xy = k
x = _reserve0
y = _reserve1
a = _amount0
b = _amount1
k = _reserve0 * _reserve1*


```solidity
function getY(ConstantProduct memory constatProduct, uint256 _amount0, uint256 _amount1)
    internal
    pure
    returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`constatProduct`|`ConstantProduct`|the values of x and y for the constant product.|
|`_amount0`|`uint256`|the amount received of token0|
|`_amount1`|`uint256`|the amount received of token1|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|amountOut|


### getY

~~~~~~~~ Sample01Struct ~~~~~~~~


```solidity
function getY(Sample01Struct memory curve, bool isSwap1For0) internal pure returns (uint256 amountOut);
```

## Errors
### InsufficientPoolDepth

```solidity
error InsufficientPoolDepth();
```

