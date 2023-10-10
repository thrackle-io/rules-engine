# ProtocolAMM
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/liquidity/ProtocolAMM.sol)

**Inherits:**
[AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md), [AMMCalculatorErrors](/src/interfaces/IErrors.sol/interface.AMMCalculatorErrors.md), [AMMErrors](/src/interfaces/IErrors.sol/interface.AMMErrors.md), [IZeroAddressError](/src/interfaces/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This is the base contract for all protocol AMMs. Token 0 is the application native token. Token 1 is the chain native token (ETH, MATIC, ETC).

*The only thing to recognize is that calculations are all done in an external calculation contract
TODO add action types purchase and sell to buy/sell functions, test purchaseWithinPeriod on buy functions.*


## State Variables
### token0
Application Token


```solidity
IERC20 public immutable token0;
```


### token1
Collateralized Token


```solidity
IERC20 public immutable token1;
```


### reserve0

```solidity
uint256 public reserve0;
```


### reserve1

```solidity
uint256 public reserve1;
```


### appManagerAddress

```solidity
address public appManagerAddress;
```


### treasuryAddress

```solidity
address treasuryAddress;
```


### calculatorAddress

```solidity
address calculatorAddress;
```


### calculator

```solidity
IProtocolAMMCalculator calculator;
```


### handler

```solidity
IProtocolAMMHandler handler;
```


## Functions
### constructor

*Must provide the addresses for both tokens that will provide liquidity*


```solidity
constructor(address _token0, address _token1, address _appManagerAddress, address _calculatorAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0`|`address`|valid ERC20 address|
|`_token1`|`address`|valid ERC20 address|
|`_appManagerAddress`|`address`|valid address of the corresponding app manager|
|`_calculatorAddress`|`address`|valid address of the corresponding calculator for the AMM|


### _update

Set the calculator and create the variable for it.

*update the reserve balances*


```solidity
function _update(uint256 _reserve0, uint256 _reserve1) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserve0`|`uint256`|amount of token0 in contract|
|`_reserve1`|`uint256`|amount of token1 in contract|


### swap

*This is the primary function of this contract. It allows for
the swapping of one token for the other.*

*arguments for checkRuleStorages: balanceFrom is token0 balance of msg.sender, balanceTo is token1 balance of msg.sender.*


```solidity
function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenIn`|`address`|address identifying the token coming into AMM|
|`_amountIn`|`uint256`|amount of the token being swapped|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|amount of the other token coming out of the AMM|


### _swap0For1

This is considered a "SELL" as the user is trading application native token 0 and receiving the chain native token 1

*This performs the swap from token0 to token1*


```solidity
function _swap0For1(uint256 _amountIn) private returns (uint256 _amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amountIn`|`uint256`|amount of token0 being swapped for unknown amount of token1|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amountOut`|`uint256`|amount of token1 coming out of the pool|


### _swap1For0

Calculate how much token they get in return
Check Rules(it's ok for this to be after the swap...it will revert on rule violation)
update the reserves with the proper amounts(adding to token0, subtracting from token1)
Assess fees. All fees are always taken out of the collateralized token(token1)
subtract fees from collateralized token
add fees to treasury
perform swap transfers

This is considered a "Purchase" as the user is trading chain native token 1 and receiving the application native token

*This performs the swap from token1 to token0*


```solidity
function _swap1For0(uint256 _amountIn) private returns (uint256 _amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amountIn`|`uint256`|amount of token0 being swapped for unknown amount of token1|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amountOut`|`uint256`|amount of token1 coming out of the pool|


### addLiquidity

Assess fees. All fees are always taken out of the collateralized token(token1)
subtract fees from collateralized token
add fees to treasury
Calculate how much token they get in return
Check Rules
update the reserves with the proper amounts(subtracting from token0, adding to token1)
transfer the token0 amount to the swapper

*This function allows contributions to the liquidity pool*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function addLiquidity(uint256 _amount0, uint256 _amount1)
    external
    appAdministratorOnly(appManagerAddress)
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount0`|`uint256`|The amount of token0 being added|
|`_amount1`|`uint256`|The amount of token1 being added|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success pass/fail|


### removeToken0

transfer funds from sender to the AMM. All the checks for available funds
and approval are done in the ERC20

*This function allows owners to remove token0 liquidity*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function removeToken0(uint256 _amount) external appAdministratorOnly(appManagerAddress) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|The amount of token0 being removed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success pass/fail|


### removeToken1

update the reserve balances
transfer the tokens to the remover

*This function allows owners to remove token1 liquidity*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function removeToken1(uint256 _amount) external appAdministratorOnly(appManagerAddress) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|The amount of token1 being removed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success pass/fail|


### setAppManagerAddress

update the reserve balances
transfer the tokens to the remover

*This function allows owners to set the app manager address*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|The address of a valid appManager|


### setCalculatorAddress

*This function allows owners to set the calculator address*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function setCalculatorAddress(address _calculatorAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_calculatorAddress`|`address`|The address of a valid AMMCalculator|


### _setCalculatorAddress

*This function allows owners to set the calculator address. It is only meant to be used at instantiation of contract*


```solidity
function _setCalculatorAddress(address _calculatorAddress) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_calculatorAddress`|`address`|The address of a valid AMMCalculator|


### getReserve0

*This function returns reserve0*


```solidity
function getReserve0() external view returns (uint256);
```

### getReserve1

*This function returns reserve1*


```solidity
function getReserve1() external view returns (uint256);
```

### setTreasuryAddress

*This function sets the treasury address*


```solidity
function setTreasuryAddress(address _treasury) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasury`|`address`|address for the treasury|


### getTreasuryAddress

*This function gets the treasury address*


```solidity
function getTreasuryAddress() external view appAdministratorOnly(appManagerAddress) returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_treasury address for the treasury|


### connectHandlerToAMM

*Connects the AMM with its handler*


```solidity
function connectHandlerToAMM(address _handlerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_handlerAddress`|`address`|of the rule processor|


### getHandlerAddress

*this function returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


