# ProtocolERC721
[Git Source](https://github.com/thrackle-io/tron/blob/fd00dd3f701afe5991226ded04be9da490ad380d/src/client/token/ERC721/ProtocolERC721.sol)

**Inherits:**
ERC721Burnable, ERC721URIStorage, ERC721Enumerable, Pausable, [ProtocolTokenCommon](/src/client/token/ProtocolTokenCommon.sol/abstract.ProtocolTokenCommon.md), [AppAdministratorOrOwnerOnly](/src/protocol/economic/AppAdministratorOrOwnerOnly.sol/contract.AppAdministratorOrOwnerOnly.md), ReentrancyGuard

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC721s


## State Variables
### _tokenIdCounter

```solidity
Counters.Counter internal _tokenIdCounter;
```


### baseUri
Base Contract URI


```solidity
string public baseUri;
```


## Functions
### constructor

*Constructor sets the name, symbol and base URI of NFT along with the App Manager Address*


```solidity
constructor(string memory _nameProto, string memory _symbolProto, address _appManagerAddress, string memory _baseUri)
    ERC721(_nameProto, _symbolProto);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_nameProto`|`string`|Name of NFT|
|`_symbolProto`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
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
function setBaseURI(string memory _baseUri) public virtual appAdministratorOrOwnerOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_baseUri`|`string`|URI to the metadata file(s) for the contract|


### tokenURI

*Function to set URI for specific token*


```solidity
function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|Id of token to update|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|tokenURI new URI for token Id|


### pause

END setters and getters ***********

*AppAdministratorOnly function takes appManagerAddress as parameter
Function pauses contract and prevents functions with whenNotPaused modifier*


```solidity
function pause() public virtual appAdministratorOnly(appManagerAddress);
```

### unpause

*Unpause the contract. Only whenNotPaused modified functions will work once called. default state of contract is unpaused.
AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function unpause() public virtual appAdministratorOnly(appManagerAddress);
```

### safeMint

Add appAdministratorOnly modifier to restrict minting privilages
Function is payable for child contracts to override with priced mint function.

*Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.*


```solidity
function safeMint(address to) public payable virtual whenNotPaused appAdministratorOrOwnerOnly(appManagerAddress);
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
    nonReentrant
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


### withdraw

*Function to withdraw Ether sent to contract*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function withdraw() public payable virtual appAdministratorOnly(appManagerAddress);
```

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
    override(ERC721, ERC721Enumerable, ERC721URIStorage)
    returns (bool);
```

### getHandlerAddress

*This function returns the handler address*


```solidity
function getHandlerAddress() external view override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


