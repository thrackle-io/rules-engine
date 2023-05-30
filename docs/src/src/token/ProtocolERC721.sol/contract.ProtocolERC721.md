# ProtocolERC721
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4f7789968960e18493ff0b85b09856f12969daac/src/token/ProtocolERC721.sol)

**Inherits:**
ERC721Burnable, ERC721URIStorage, ERC721Enumerable, Pausable, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC721s


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
Counters.Counter private _tokenIdCounter;
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
### constructor

*Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
constructor(
    string memory _name,
    string memory _symbol,
    address _appManagerAddress,
    address _ruleProcessor,
    bool _upgradeMode,
    string memory _baseUri
) ERC721(_name, _symbol);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_ruleProcessor`|`address`|Address of the protocol rule processor|
|`_upgradeMode`|`bool`|token deploys a Handler contract, false = handler deployed, true = upgraded token contract and no handler. _upgradeMode is also passed to Handler contract to deploy a new data contract with the handler.|
|`_baseUri`|`string`|URI for the base token|


### _baseURI

setters and getters for rules  *********

*Function to return baseUri for contract*


```solidity
function _baseURI() internal view override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|baseUri URI link to NFT metadata|


### setBaseURI

this is called in the constructor and can be called to update URI metadata pointer

*Function to set URI for contract.*


```solidity
function setBaseURI(string memory _baseUri) public appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_baseUri`|`string`|URI to the metadata file(s) for the contract|


### pause

END setters and getters ***********

*AppAdministratorOnly function takes appManagerAddress as parameter
Function puases contract and prevents functions with whenNotPaused modifier*


```solidity
function pause() public appAdministratorOnly(appManagerAddress);
```

### unpause

*Unpause the contract. Only whenNotPaused modified functions will work once called. default state of contract is unpaused.
AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function unpause() public appAdministratorOnly(appManagerAddress);
```

### safeMint

Add appAdministratorOnly modifier to restrict minting privilages

*Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.*


```solidity
function safeMint(address to) public virtual whenNotPaused;
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
    override(ERC721, ERC721Enumerable)
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`tokenId`|`uint256`|Id of token to be transferred|
|`batchSize`|`uint256`|the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will represent the first id to start the batch.|


### _burn

The following functions are overrides required by Solidity.

*Function to burn or remove token from circulation*


```solidity
function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|Id of token to be burned|


### tokenURI

*Function to set URI for specific token*


```solidity
function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|Id of token to update|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|tokenURI new URI for token Id|


### withdraw

*Function to withdraw Ether sent to contract*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function withdraw() public payable appAdministratorOnly(appManagerAddress);
```

### setAppManagerAddress

*Function to set the appManagerAddress and connect to the new appManager*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress);
```

### supportsInterface

*Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.
This function call must use less than 30 000 gas.*


```solidity
function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool);
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


## Errors
### ZeroAddress

```solidity
error ZeroAddress();
```

