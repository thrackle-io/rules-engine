# ApplicationERC721
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/example/ApplicationERC721.sol)

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
    address _erc721HandlerAddress,
    string memory baseUri
) ProtocolERC721(_name, _symbol, _appManagerAddress, _erc721HandlerAddress, baseUri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_erc721HandlerAddress`|`address`|Address of this ERC721's handler|
|`baseUri`|`string`|URI for the base token|


