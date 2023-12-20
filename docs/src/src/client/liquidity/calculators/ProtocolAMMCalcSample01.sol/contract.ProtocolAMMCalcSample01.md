# ProtocolAMMCalcSample01
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/ProtocolAMMCalcSample01.sol)

**Inherits:**
[IProtocolAMMFactoryCalculator](/src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol/abstract.IProtocolAMMFactoryCalculator.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contains the calculations for AMM swap.

*This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
as needed. It contains an example constant that uses ratio x/y. It is built through ProtocolAMMCalculationFactory*


## State Variables
### f_tracker

```solidity
int256 f_tracker;
```


### g_tracker

```solidity
int256 g_tracker;
```


## Functions
### constructor

*Set up the calculator and appManager for permissions*


```solidity
constructor(int256 _f_tracker, int256 _g_tracker, address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_f_tracker`|`int256`|f(x) tracker value|
|`_g_tracker`|`int256`|f(x) tracker value|
|`_appManagerAddress`|`address`|appManager address|


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
    override
    returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|not used in this case|
|`_reserve1`|`uint256`|not used in this case|
|`_amount0`|`uint256`|amount of token0 possibly coming into the pool|
|`_amount1`|`uint256`|amount of token1 possibly coming into the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|amount of alternate coming out of the pool|


### simulateSwap

*This performs the swap from ERC20s to NFTs. It is a linear calculation.*


```solidity
function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    public
    view
    override
    returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|not used in this case|
|`_reserve1`|`uint256`|not used in this case|
|`_amount0`|`uint256`|amount of token0 possibly coming into the pool|
|`_amount1`|`uint256`|amount of token1 possibly coming into the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|amountOut|


### setFTracker

set the F Tracker value


```solidity
function setFTracker(int256 _f_tracker) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_f_tracker`|`int256`|f(x) tracker value|


### getFTracker

*Retrieve the F Tracker value*


```solidity
function getFTracker() external view returns (int256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|f_tracker|


### setGTracker

set the G Tracker value


```solidity
function setGTracker(int256 _g_tracker) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_g_tracker`|`int256`|f(x) tracker value|


### getGTracker

*Retrieve the G Tracker value*


```solidity
function getGTracker() external view returns (int256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|g_tracker|


