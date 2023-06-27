# ApplicationERC721
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2955538441cd4ad2d51a27d7c28af7eec4cd8814/src/example/ApplicationERC721.sol)

**Inherits:**
[ProtocolERC721](/src/token/ProtocolERC721.sol/contract.ProtocolERC721.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs should use.
During deployment, _handlerAddress = ERC721Handler contract address
_appManagerAddress = AppManager contract address


## Functions
### constructor

*Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
constructor(
    string memory _name,
    string memory _symbol,
    address _appManagerAddress,
    address _ruleProcessorProxyAddress,
    bool _upgradeMode,
    string memory _baseUri
) ProtocolERC721(_name, _symbol, _appManagerAddress, _ruleProcessorProxyAddress, _upgradeMode, baseUri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_ruleProcessorProxyAddress`|`address`|of token rule router proxy address|
|`_upgradeMode`|`bool`||
|`_baseUri`|`string`|URI for the base token|


