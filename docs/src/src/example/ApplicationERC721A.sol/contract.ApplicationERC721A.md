# ApplicationERC721A
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/de9d46fc7f857fca8d253f1ed09221b1c3873dd9/src/example/ApplicationERC721A.sol)

**Inherits:**
[ProtocolERC721A](/src/token/ProtocolERC721A.sol/contract.ProtocolERC721A.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs should use.

*During deployment,  _appManagerAddress = AppManager contract address*

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
    ProtocolERC721A(_name, _symbol, _appManagerAddress, baseUri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_baseUri`|`string`|URI for the base token|


### mint


```solidity
function mint(uint256 quantity) external payable;
```

