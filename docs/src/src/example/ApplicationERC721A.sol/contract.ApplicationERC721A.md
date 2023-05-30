# ApplicationERC721A
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/49ab19f6a1a98efed1de2dc532ff3da9b445a7cb/src/example/ApplicationERC721A.sol)

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
    address _appManagerAddress,
    address _ruleProcessorProxyAddress,
    bool _upgradeMode,
    string memory _baseUri
) ProtocolERC721A(_name, _symbol, _appManagerAddress, _ruleProcessorProxyAddress, _upgradeMode, baseUri);
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


### mint


```solidity
function mint(uint256 quantity) external payable;
```

