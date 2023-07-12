# ApplicationAMMHandler
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/de9d46fc7f857fca8d253f1ed09221b1c3873dd9/src/example/liquidity/ApplicationAMMHandler.sol)

**Inherits:**
[ProtocolAMMHandler](/src/liquidity/ProtocolAMMHandler.sol/contract.ProtocolAMMHandler.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Any rule checks may be updated by modifying this contract and redeploying.

*This contract performs all the rule checks related to the the AMM that implements it.*


## Functions
### constructor

*Constructor sets the App Manager and token rule router Address*


```solidity
constructor(address _appManagerAddress, address _ruleProcessorProxyAddress)
    ProtocolAMMHandler(_appManagerAddress, _ruleProcessorProxyAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|App Manager Address|
|`_ruleProcessorProxyAddress`|`address`|Rule Router Proxy Address|


