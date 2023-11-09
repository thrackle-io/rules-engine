# ApplicationERC721
<<<<<<< HEAD:docs/src/src/example/ERC721/not-upgradeable/ApplicationERC721FreeMint.sol/contract.ApplicationERC721.md
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/example/ERC721/not-upgradeable/ApplicationERC721FreeMint.sol)
=======
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/example/ERC721/ApplicationERC721FreeMint.sol)
>>>>>>> external:docs/src/src/example/ERC721/ApplicationERC721FreeMint.sol/contract.ApplicationERC721.md

**Inherits:**
[ProtocolERC721](/src/token/ERC721/ProtocolERC721.sol/contract.ProtocolERC721.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation of the protocol ERC721 where minting is free and open to anybody.


## State Variables
### _tokenIdCounter

```solidity
Counters.Counter private _tokenIdCounter;
```


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


### safeMint

This allows EVERYBODY TO MINT FOR FREE.

*Function mints a new token to anybody. Don't enabled this function if you are not sure about what you're doing.*


```solidity
function safeMint(address to) public payable override whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|


