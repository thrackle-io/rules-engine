# ApplicationAMMHandler
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/example/liquidity/ApplicationAMMHandler.sol)

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
constructor(address _appManagerAddress, address _ruleProcessorProxyAddress, address _assetAddress)
    ProtocolAMMHandler(_appManagerAddress, _ruleProcessorProxyAddress, _assetAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|App Manager Address|
|`_ruleProcessorProxyAddress`|`address`|Rule Router Proxy Address|
|`_assetAddress`|`address`|address of the congtrolling address|


