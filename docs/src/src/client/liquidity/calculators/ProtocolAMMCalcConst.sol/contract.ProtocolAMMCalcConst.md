# ProtocolAMMCalcConst
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/ProtocolAMMCalcConst.sol)

**Inherits:**
[IProtocolAMMFactoryCalculator](/src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol/abstract.IProtocolAMMFactoryCalculator.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contains the calculations for AMM swap.

*This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
as needed. It contains an example constant that uses ratio x/y. It is built through ProtocolAMMCalculationFactory*


## State Variables
### constRatio

```solidity
ConstantRatio public constRatio;
```


## Functions
### constructor

x represents token0 and y represents token1

*Set up the ratio and appManager for permissions*


```solidity
constructor(ConstantRatio memory _constRatio, address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_constRatio`|`ConstantRatio`|the values of x and y for the constant ratio|
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

*This performs the swap from token0 to token1. It is a linear calculation.*


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
|`_amount0`|`uint256`|amount of token0 coming to the pool|
|`_amount1`|`uint256`|amount of token1 coming to the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|_amountOut|


### setRatio

x represents token0 and y represents token1

*Sets the ratio*


```solidity
function setRatio(ConstantRatio memory _constRatio) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_constRatio`|`ConstantRatio`|the values of x and y for the constant ratio|


### _setRatio

x represents token0 and y represents token1

*Sets the ratio*


```solidity
function _setRatio(ConstantRatio memory _constRatio) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_constRatio`|`ConstantRatio`|the values of x and y for the constant ratio|


