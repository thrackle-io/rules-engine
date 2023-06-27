# ApplicationERC20Handler
[Git Source](https://github.com/thrackle-io/Tron/blob/89e7f7b48d79c8e2bc6476fb1601cc9680f2c384/src/example/ApplicationERC20Handler.sol)

**Inherits:**
[ProtocolERC20Handler](/src/token/ProtocolERC20Handler.sol/contract.ProtocolERC20Handler.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Any rule checks may be updated by modifying this contract, redeploying, and pointing the ERC20 to the new version.

*This contract performs all the rule checks related to the the ERC20 that implements it. This implementation is all that is needed
to deploy in order to gain all the rule functionality for a token*


## Functions
### constructor

*Constructor sets params*


```solidity
constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, bool _upgradeMode)
    ProtocolERC20Handler(_ruleProcessorProxyAddress, _appManagerAddress, _upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|address of the protocol's Rule Processor contract.|
|`_appManagerAddress`|`address`|address of the application AppManager.|
|`_upgradeMode`|`bool`|specifies whether this is a fresh CoinHandler or an upgrade replacement.|


