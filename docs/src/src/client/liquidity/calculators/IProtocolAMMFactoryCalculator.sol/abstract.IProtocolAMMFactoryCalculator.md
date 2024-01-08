# IProtocolAMMFactoryCalculator
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol)

**Inherits:**
[AppAdministratorOnly](/src/protocol/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [AMMCalculatorErrors](/src/common/IErrors.sol/interface.AMMCalculatorErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contains the calculations for AMM swap.

*This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
as needed.*


## State Variables
### appManagerAddress

```solidity
address public appManagerAddress;
```


## Functions
### calculateSwap

*This performs the swap from token0 to token1*


```solidity
function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    external
    virtual
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


### simulateSwap

*This performs the swap from token0 to token1*


```solidity
function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1)
    external
    view
    virtual
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


