# ProtocolAMMFactory
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/ProtocolAMMFactory.sol)

**Inherits:**
[AppAdministratorOnly](/src/protocol/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IAMMFactoryEvents](/src/common/IEvents.sol/interface.IAMMFactoryEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This is a factory responsible for creating Protocol AMM

*This will allow any application to create a specific AMM.*


## State Variables
### protocolAMMCalculatorFactory

```solidity
ProtocolAMMCalculatorFactory protocolAMMCalculatorFactory;
```


## Functions
### constructor


```solidity
constructor(address _protocolAMMCalculatorFactory);
```

### createERC20AMM

*Create an AMM. Must provide the addresses for both tokens that will provide liquidity*


```solidity
function createERC20AMM(address _token0, address _token1, address _appManagerAddress, address _calculatorAddress)
    public
    returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0`|`address`|valid ERC20 address|
|`_token1`|`address`|valid ERC20 address|
|`_appManagerAddress`|`address`|valid address of the corresponding app manager|
|`_calculatorAddress`|`address`|valid address of the corresponding calculator for the AMM|


### createERC721AMM

*Create an AMM. Must provide the addresses for both tokens that will provide liquidity*


```solidity
function createERC721AMM(
    address _ERC20Token,
    address _ERC721Token,
    address _appManagerAddress,
    address _calculatorAddress
) public returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ERC20Token`|`address`|valid ERC20 address|
|`_ERC721Token`|`address`|valid ERC721 address|
|`_appManagerAddress`|`address`|valid address of the corresponding app manager|
|`_calculatorAddress`|`address`|valid address of the corresponding calculator for the AMM|


### createLinearAMM

*This creates a linear AMM and calculation module.*


```solidity
function createLinearAMM(address _token0, address _token1, LinearInput memory curve, address _appManagerAddress)
    external
    returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0`|`address`|valid ERC20 address|
|`_token1`|`address`|valid ERC20 address|
|`curve`|`LinearInput`|LinearInput for the linear curve equation|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


### createDualLinearERC721AMM

*This creates a linear AMM and calculation module.*


```solidity
function createDualLinearERC721AMM(
    address _ERC20Token,
    address _ERC721Token,
    LinearInput memory buyCurve,
    LinearInput memory sellCurve,
    address _appManagerAddress
) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ERC20Token`|`address`|valid ERC20 address|
|`_ERC721Token`|`address`|valid ERC721 address|
|`buyCurve`|`LinearInput`|LinearInput for buy curve|
|`sellCurve`|`LinearInput`|LinearInput for sell curve|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


### createConstantProductAMM

*This creates a linear AMM and calculation module.*


```solidity
function createConstantProductAMM(address _token0, address _token1, address _appManagerAddress)
    external
    returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0`|`address`|valid ERC20 address|
|`_token1`|`address`|valid ERC20 address|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


### createConstantAMM

x represents token0 and y represents token1

*This creates a constant AMM and calculation module.*


```solidity
function createConstantAMM(
    address _token0,
    address _token1,
    ConstantRatio memory _constantRatio,
    address _appManagerAddress
) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0`|`address`|valid ERC20 address|
|`_token1`|`address`|valid ERC20 address|
|`_constantRatio`|`ConstantRatio`|the values of x and y for the constant ratio|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


### createSample01AMM

*This creates a sample01 AMM and calculation module.*


```solidity
function createSample01AMM(
    address _token0,
    address _token1,
    int256 _f_tracker,
    int256 _g_tracker,
    address _appManagerAddress
) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0`|`address`|valid ERC20 address|
|`_token1`|`address`|valid ERC20 address|
|`_f_tracker`|`int256`|f(x) tracker value|
|`_g_tracker`|`int256`|g(x) tracker value|
|`_appManagerAddress`|`address`|address of the application's appManager|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_calculatorAddress|


