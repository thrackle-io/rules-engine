# ApplicationERC721AdminOrOwnerMint
[Git Source](https://github.com/thrackle-io/tron/blob/f405cfa7d52aca0d1bdf3d82da9748579a0bb635/src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol)

**Inherits:**
[ProtocolERC721](/src/client/token/ERC721/ProtocolERC721.sol/contract.ProtocolERC721.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation of the protocol ERC721 where minting is only available for app administrators or contract owners.


## Functions
### constructor

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


