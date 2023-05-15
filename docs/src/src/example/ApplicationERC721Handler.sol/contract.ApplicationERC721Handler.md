# ApplicationERC721Handler
[Git Source](https://github.com/thrackle-io/Tron/blob/afc52571532b132ea1dea91ad1d1f1af07381e8a/src/example/ApplicationERC721Handler.sol)

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
constructor(address _tokenRuleRouterProxyAddress, address _appManagerAddress)
    ProtocolERC721Handler(_tokenRuleRouterProxyAddress, _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenRuleRouterProxyAddress`|`address`|Address of Token Rule Router Proxy|
|`_appManagerAddress`|`address`|Address of App Manager|


