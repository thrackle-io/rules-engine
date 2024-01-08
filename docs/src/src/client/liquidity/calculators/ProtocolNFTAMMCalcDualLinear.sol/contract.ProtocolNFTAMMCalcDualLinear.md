# ProtocolNFTAMMCalcDualLinear
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/ProtocolNFTAMMCalcDualLinear.sol)

**Inherits:**
[IProtocolAMMFactoryCalculator](/src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol/abstract.IProtocolAMMFactoryCalculator.md), [CurveErrors](/src/common/IErrors.sol/interface.CurveErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
as needed. It contains an example linear. It is built through ProtocolAMMCalculationFactory*


## State Variables
### M_PRECISION_DECIMALS

```solidity
uint256 constant M_PRECISION_DECIMALS = 8;
```


### ATTO

```solidity
uint256 constant ATTO = 10 ** 18;
```


### Y_MAX

```solidity
uint256 constant Y_MAX = 1_000_000_000_000_000_000_000_000 * ATTO;
```


### M_MAX

```solidity
uint256 constant M_MAX = 1_000_000_000_000_000_000_000_000 * 10 ** M_PRECISION_DECIMALS;
```


### buyCurve

```solidity
LinearWholeB public buyCurve;
```


### sellCurve

```solidity
LinearWholeB public sellCurve;
```


### q
that q is a unit, which means we are assuming that the AMM is the ONLY source of NFTs.
In other words, q = ERC721Contract.totalSupply() - ERC721Contract.balanceOf(AMM_ADDRESS).

*tracks how many NFTs have been put in circulation by the AMM.
If the AMM has sold 10 NFTs and then "bought" back 7, then the value of q will be 3.*


```solidity
uint256 public q;
```


## Functions
### constructor

*constructor*


```solidity
constructor(LinearInput memory _buyCurve, LinearInput memory _sellCurve, address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_buyCurve`|`LinearInput`|the definition of the buyCurve|
|`_sellCurve`|`LinearInput`|the definition of the sellCurve|
|`_appManagerAddress`|`address`|the address of the appManager|


### calculateSwap

*This performs the swap from ERC20s to NFTs. It is a linear calculation.*


```solidity
function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amountERC20, uint256 _amountNFT)
    external
    override
    returns (uint256 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|not used in this case.|
|`_reserve1`|`uint256`|not used in this case.|
|`_amountERC20`|`uint256`|amount of ERC20 coming out of the pool|
|`_amountNFT`|`uint256`|amount of NFTs coming out of the pool (restricted to 1 for now)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|price|


### simulateSwap

*This performs the swap from ERC20s to NFTs. It is a linear calculation.*


```solidity
function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amountERC20, uint256 _amountNFT)
    public
    view
    override
    returns (uint256 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|not used in this case.|
|`_reserve1`|`uint256`|not used in this case.|
|`_amountERC20`|`uint256`|amount of ERC20 coming into the pool|
|`_amountNFT`|`uint256`|amount of NFTs coming into the pool (restricted to 1 for now)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|price|


### set_q

only AppAdministrators can perform this operation

*sets the value of q*


```solidity
function set_q(uint256 _q) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_q`|`uint256`|the new value of q.|


### _calculateBuy

*calculates the price for a buy with current q*


```solidity
function _calculateBuy() internal view returns (uint256 price);
```

### _calculateSell

*calculates the price for a sell with current q*


```solidity
function _calculateSell() internal view returns (uint256 price);
```

### setBuyCurve

*sets the buyCurve*


```solidity
function setBuyCurve(LinearInput memory _buyCurve) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_buyCurve`|`LinearInput`|the definition of the new buyCurve|


### setSellCurve

*sets the sellCurve*


```solidity
function setSellCurve(LinearInput memory _sellCurve) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sellCurve`|`LinearInput`|the definition of the new sellCurve|


### _validateSingleCurve

#### Validation Functions ####

*validates that the definition of a curve is within the safe mathematical limits*


```solidity
function _validateSingleCurve(LinearInput memory curve) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`curve`|`LinearInput`|the definition of the curve|


### _validateCurvePair

this is an overloaded function. In this case, both parameters are of the LinearInput type

*validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve,
that they don't intersect, and that they tend to diverge.*


```solidity
function _validateCurvePair(LinearInput memory _buyCurve, LinearInput memory _sellCurve) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_buyCurve`|`LinearInput`|the definition of the buyCurve input|
|`_sellCurve`|`LinearInput`|the definition of the sellCurve input|


### _validateCurvePair

this is an overloaded function. In this case, the buyCurve is of the LinearInput type while the sellCurve
is of the Line type

*validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve,
that they don't intersect, and that they tend to diverge.*


```solidity
function _validateCurvePair(LinearInput memory _buyCurve, LinearWholeB memory _sellCurve) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_buyCurve`|`LinearInput`|the definition of the buyCurve stored in the contract|
|`_sellCurve`|`LinearWholeB`|the definition of the sellCurve input|


### _validateCurvePair

this is an overloaded function. In this case, the buyCurve is of the Line type while the sellCurve
is of the LinearInput type

*validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve,
that they don't intersect, and that they tend to diverge.*


```solidity
function _validateCurvePair(LinearWholeB memory _buyCurve, LinearInput memory _sellCurve) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_buyCurve`|`LinearWholeB`|the definition of the buyCurve input|
|`_sellCurve`|`LinearInput`|the definition of the sellCurve stored in the contract|


