# ProtocolAMMCalculatorFactory
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/ProtocolAMMCalculatorFactory.sol)

**Inherits:**
[AppAdministratorOnly](/src/protocol/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IAMMFactoryEvents](/src/common/IEvents.sol/interface.IAMMFactoryEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This is a factory responsible for creating Protocol AMM calculators: Constant, Linear, Sigmoid

*This will allow any application to create and attach a calculation module to a specific AMM.*


## State Variables
### appManagerAddress

```solidity
address appManagerAddress;
```


## Functions
### constructor


```solidity
constructor();
```

### createLinear

*This creates a linear calculation module.*


```solidity
function createLinear(LinearInput memory curve, address _appManagerAddress) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`curve`|`LinearInput`|the definition of the curve's equation|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


### createDualLinearNFT

a LinearInput has the shape {uint256 m; uint256 b}
m* is the slope of the line expressed with 8 decimals of precision. Input of 100000001 means -> 1.00000001
b* is the intersection of the line with the ordinate axis expressed in atto (18 decimals of precision). 1 ^ 10 ** 18 means -> 1

*This creates a linear calculation module.*


```solidity
function createDualLinearNFT(LinearInput memory buyCurve, LinearInput memory sellCurve, address _appManagerAddress)
    external
    returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`buyCurve`|`LinearInput`|the definition of the buyCurve|
|`sellCurve`|`LinearInput`|the definition of the sellCurve|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


### createConstantProduct

*This creates a linear calculation module.*


```solidity
function createConstantProduct(address _appManagerAddress) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


### createConstant

*This creates a constant calculation module.*


```solidity
function createConstant(ConstantRatio memory _constRatio, address _appManagerAddress) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_constRatio`|`ConstantRatio`|the values of x and y for the constant ratio|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


### createSample01

*This creates a sample 1 calculation module.*


```solidity
function createSample01(int256 _f_tracker, int256 _g_tracker, address _appManagerAddress) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_f_tracker`|`int256`|f(x) tracker value|
|`_g_tracker`|`int256`|g(x) tracker value|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


