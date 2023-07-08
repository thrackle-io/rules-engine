# ApplicationERC721
[Git Source](https://github.com/thrackle-io/Tron/blob/239d60d1c3cbbef1a9f14ff953593a8a908ddbe0/src/example/ApplicationERC721.sol)

**Inherits:**
[ProtocolERC721](/src/token/ProtocolERC721.sol/contract.ProtocolERC721.md), Ownable

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs should use.
During deployment, _handlerAddress = ERC721Handler contract address
_appManagerAddress = AppManager contract address

*This contract contains optional functions commented out. These functions allow for: Priced Mint for user minting, AppAdministratorOnly Minting or Contract Owner Only Minting.
Only one safeMint function can be used at a time. Comment out all other safeMint functions and variables used for that function.*


## Functions
### constructor

Optional Function Variables and Errors. Uncomment these if using option functions:
Mint Fee
Treasury Address
Contract Owner Minting

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


