# ProtocolERC721U
[Git Source](https://github.com/thrackle-io/Tron/blob/89e7f7b48d79c8e2bc6476fb1601cc9680f2c384/src/token/ProtocolERC721U.sol)

**Inherits:**
Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, UUPSUpgradeable, [AppAdministratorOnlyU](/src/economic/AppAdministratorOnlyU.sol/contract.AppAdministratorOnlyU.md), [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md), PausableUpgradeable

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC721Upgradeables


## State Variables
### appManagerAddress

```solidity
address public appManagerAddress;
```


### handlerAddress

```solidity
address public handlerAddress;
```


### handler

```solidity
ProtocolERC721Handler handler;
```


### appManager

```solidity
IAppManager appManager;
```


### _tokenIdCounter

```solidity
CountersUpgradeable.Counter private _tokenIdCounter;
```


### baseUri
Base Contract URI


```solidity
string public baseUri;
```


### VERSION
keeps track of RULE enum version and other features


```solidity
uint8 public constant VERSION = 1;
```


## Functions
### initialize

*Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
function initialize(
    string memory _name,
    string memory _symbol,
    address _appManagerAddress,
    address _ruleProcessorProxyAddress,
    bool _upgradeMode,
    string memory _baseUri
) external virtual appAdministratorOnly(_appManagerAddress) initializer;
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


### _initializeProtocol

*Private Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
function _initializeProtocol(
    address _appManagerAddress,
    address _ruleProcessorProxyAddress,
    bool _upgradeMode,
    string memory _baseUri
) private onlyInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_ruleProcessorProxyAddress`|`address`|of token rule router proxy address|
|`_upgradeMode`|`bool`||
|`_baseUri`|`string`|URI for the base token|


### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

### _burn

*Function to burn or remove token from circulation*


```solidity
function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|Id of token to be burned|


### _baseURI

*Function to return baseUri for contract*


```solidity
function _baseURI() internal view override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|baseUri URI link to NFT metadata|


### tokenURI


```solidity
function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    returns (string memory);
```

### setBaseURI

this is called in the constructor and can be called to update URI metadata pointer

*Function to set URI for contract.*


```solidity
function setBaseURI(string memory _baseUri) public virtual appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_baseUri`|`string`|URI to the metadata file(s) for the contract|


### supportsInterface

*Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.
This function call must use less than 30 000 gas.*


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable)
    returns (bool);
```

### safeMint

END setters and getters ***********

Add appAdministratorOnly modifier to restrict minting privilages

*Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.*


```solidity
function safeMint(address to) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|


### _beforeTokenTransfer

*Function called before any token transfers to confirm transfer is within rules of the protocol*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
    internal
    override(ERC721Upgradeable, ERC721EnumerableUpgradeable);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`tokenId`|`uint256`|Id of token to be transferred|
|`batchSize`|`uint256`|the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will represent the first id to start the batch.|


### withdraw

*Function to withdraw Ether sent to contract*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function withdraw() public payable virtual appAdministratorOnly(appManagerAddress);
```

### setAppManagerAddress

*Function to set the appManagerAddress and connect to the new appManager*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress);
```

### deployHandler

*This function is called at deployment in the constructor to deploy the Handler Contract for the Token.*


```solidity
function deployHandler(address _ruleProcessor, address _appManagerAddress, bool _upgradeModeHandler)
    private
    returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessor`|`address`|address of the rule processor|
|`_appManagerAddress`|`address`|address of the Application Manager Contract|
|`_upgradeModeHandler`|`bool`|specifies whether this is a fresh Handler or an upgrade replacement.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress address of the new Handler Contract|


### connectHandlerToToken

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


### getHandlerAddress

*this function returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


## Errors
### ZeroAddress

```solidity
error ZeroAddress();
```

