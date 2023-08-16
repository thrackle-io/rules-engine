# ApplicationERC721
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/d0344b27291308c442daefb74b46bb81740099e4/src/example/ApplicationERC721.sol)

**Inherits:**
[ProtocolERC721](/src/token/ProtocolERC721.sol/contract.ProtocolERC721.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs should use.
During deployment, _handlerAddress = ERC721Handler contract address
_appManagerAddress = AppManager contract address

*This contract contains 3 different safeMint implementations: priced minting, free minting and app-administrator-only minting. The safeMint is by default
restricted to app-administrators or contract-owner, but it is possible to override such configuration and choose any of the other 3 options in here, or even
creating a different safeMint implementation. However, bare in mind that only one safeMint function can exist at a time in the contract unless polymorphism is
used. If it is wished to override the default minting restriction from app-administrators or contract-owners, select the desired safeMint function by simply
uncommenting the desired implementations and its variables, or write your own implementation that overrides the default safeMint function.*


## Functions
### constructor

Optional Function Variables and Errors. Uncomment these if using option functions:
Mint Fee
Treasury Address

*Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
constructor(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri)
    ProtocolERC721(_name, _symbol, _appManagerAddress, _baseUri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_baseUri`|`string`|URI for the base token|


