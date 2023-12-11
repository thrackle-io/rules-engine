# ProtocolAMMCalcLinear
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/ProtocolAMMCalcLinear.sol)

**Inherits:**
[IProtocolAMMFactoryCalculator](/src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol/abstract.IProtocolAMMFactoryCalculator.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contains the calculations for AMM swap. y = mx + b
y = token0 amount
x = token1 amount

*This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
as needed. It contains an example linear. It is built through ProtocolAMMCalculationFactory*


## State Variables
### Y_MAX

```solidity
uint256 constant Y_MAX = 100_000 * 10 ** 18;
```


### M_MAX

```solidity
uint256 constant M_MAX = 100 * 10 ** 8;
```


### M_PRECISION_DECIMALS

```solidity
uint8 constant M_PRECISION_DECIMALS = 8;
```


### B_PRECISION_DECIMALS

```solidity
uint8 constant B_PRECISION_DECIMALS = 18;
```


### curve

```solidity
LinearFractionB public curve;
```


## Functions
### constructor

*Set up the calculator and appManager for permissions*


```solidity
constructor(LinearInput memory _curve, address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_curve`|`LinearInput`|the definition of the linear ecuation|
|`_appManagerAddress`|`address`|appManager address|


### calculateSwap

*This performs the swap from token0 to token1. It is a linear calculation.*


```solidity
function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    external
    view
    override
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|amount of token0 in the pool|
|`_reserve1`|`uint256`|amount of token1 in the pool|
|`_amount0`|`uint256`|amount of token1 coming to the pool|
|`_amount1`|`uint256`|amount of token1 coming to the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|_amountOut|


### simulateSwap

*This performs the swap from ERC20s to NFTs. It is a linear calculation.*


```solidity
function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    public
    view
    override
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|amount of token0 in the pool|
|`_reserve1`|`uint256`|amount of token1 in the pool|
|`_amount0`|`uint256`|amount of token1 coming to the pool|
|`_amount1`|`uint256`|amount of token1 coming to the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price|


### setCurve

*Set the equation variables*


```solidity
function setCurve(LinearInput memory _curve) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_curve`|`LinearInput`|the definition of the linear ecuation|


### _setCurve

*Set the equation variables*


```solidity
function _setCurve(LinearInput memory _curve) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_curve`|`LinearInput`|the definition of the linear ecuation|


### _validateSingleCurve

*validates that the definition of a curve is within the safe mathematical limits*


```solidity
function _validateSingleCurve(LinearInput memory _curve) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_curve`|`LinearInput`|the definition of the curve|


