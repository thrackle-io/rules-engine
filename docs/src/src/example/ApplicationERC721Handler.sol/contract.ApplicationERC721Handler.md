# ApplicationERC721Handler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/a2d57139b7236b5b0e9a0727e55f81e5332cd216/src/example/ApplicationERC721Handler.sol)

**Inherits:**
[ProtocolERC721Handler](/src/token/ProtocolERC721Handler.sol/contract.ProtocolERC721Handler.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract is the interaction point for the application ecosystem to the protocol

*This contract is an example for how to implement the ProtocolERC721Handler. All ERC721 rules are set up through this contract*


## Functions
### constructor

*Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode)
    ProtocolERC721Handler(_ruleProcessorProxyAddress, _appManagerAddress, _assetAddress, _upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|Address of Token Rule Router Proxy|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_assetAddress`|`address`|Address of the controlling address|
|`_upgradeMode`|`bool`|specifies whether this is a fresh Handler or an upgrade replacement.|


