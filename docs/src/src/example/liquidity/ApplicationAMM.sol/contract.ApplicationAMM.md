# ApplicationAMM
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/example/liquidity/ApplicationAMM.sol)

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


