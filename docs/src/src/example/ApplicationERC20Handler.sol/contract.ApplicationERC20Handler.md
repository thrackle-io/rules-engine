# ApplicationERC20Handler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/108c58e2bb8e5c2e5062cebb48a41dcaadcbfcd8/src/example/ERC20/ApplicationERC20Handler.sol)

**Inherits:**
[ProtocolERC20Handler](/src/token/ERC20/ProtocolERC20Handler.sol/contract.ProtocolERC20Handler.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Any rule checks may be updated by modifying this contract, redeploying, and pointing the ERC20 to the new version.

*This contract performs all the rule checks related to the the ERC20 that implements it. This implementation is all that is needed
to deploy in order to gain all the rule functionality for a token*


## Functions
### constructor

*Constructor sets params*


```solidity
constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode)
    ProtocolERC20Handler(_ruleProcessorProxyAddress, _appManagerAddress, _assetAddress, _upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|address of the protocol's Rule Processor contract.|
|`_appManagerAddress`|`address`|address of the application AppManager.|
|`_assetAddress`|`address`|address of the controlling asset.|
|`_upgradeMode`|`bool`|specifies whether this is a fresh CoinHandler or an upgrade replacement.|


