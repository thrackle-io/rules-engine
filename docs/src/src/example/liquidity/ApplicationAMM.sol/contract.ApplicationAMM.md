# ApplicationAMM
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/example/liquidity/ApplicationAMM.sol)

**Inherits:**
[ProtocolAMM](/src/liquidity/ProtocolAMM.sol/contract.ProtocolAMM.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This is the example implementation for a protocol AMM.

*All the good stuff happens in the ProtocolAMM*


## Functions
### constructor

*Must provide the addresses for both tokens that will provide liquidity*


```solidity
constructor(
    address _token0,
    address _token1,
    address _appManagerAddress,
    address _calculatorAddress,
    address _ammHandlerAddress
) ProtocolAMM(_token0, _token1, _appManagerAddress, _calculatorAddress, _ammHandlerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0`|`address`|valid ERC20 address|
|`_token1`|`address`|valid ERC20 address|
|`_appManagerAddress`|`address`|valid address of the corresponding app manager|
|`_calculatorAddress`|`address`|valid address of the corresponding calculator for the AMM|
|`_ammHandlerAddress`|`address`|valid address of the corresponding handler for the AMM|


