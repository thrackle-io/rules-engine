# ApplicationERC721A
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/example/ApplicationERC721A.sol)

**Inherits:**
[ProtocolERC721A](/src/token/ProtocolERC721A.sol/contract.ProtocolERC721A.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs should use.

*During deployment,  _appManagerAddress = AppManager contract address*


## Functions
### constructor

*Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
constructor(
    string memory _name,
    string memory _symbol,
    address _erc721HandlerAddress,
    address _appManagerAddress,
    string memory baseUri
) ProtocolERC721A(_name, _symbol, _erc721HandlerAddress, _appManagerAddress, baseUri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_erc721HandlerAddress`|`address`|Address of this ERC721a's handler|
|`_appManagerAddress`|`address`|Address of App Manager|
|`baseUri`|`string`|URI for the base token|


### mint


```solidity
function mint(uint256 quantity) external payable;
```

