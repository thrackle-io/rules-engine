# ApplicationERC721
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/35ec513a185f22e7ba035815b9ced8c0ef1497a9/src/example/ERC721/ApplicationERC721.sol)

**Inherits:**
ERC721, AccessControl, [IProtocolToken](/src/client/token/IProtocolToken.sol/interface.IProtocolToken.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), ReentrancyGuard, ERC721Burnable, ERC721Enumerable

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4

This is an example implementation that App Devs should use.

*During deployment _tokenName _tokenSymbol _tokenAdmin are set in constructor*


## State Variables
### _tokenIdCounter

```solidity
Counters.Counter internal _tokenIdCounter;
```


### TOKEN_ADMIN_ROLE

```solidity
bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");
```


### handlerAddress

```solidity
address private handlerAddress;
```


### baseUri
Base Contract URI


```solidity
string public baseUri;
```


## Functions
### constructor

*Constructor sets params*


```solidity
constructor(string memory _name, string memory _symbol, address _tokenAdmin, string memory _baseUri)
    ERC721(_name, _symbol);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of the token|
|`_symbol`|`string`|Symbol of the token|
|`_tokenAdmin`|`address`|Token Admin address|
|`_baseUri`|`string`||


### _baseURI

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
function setBaseURI(string memory _baseUri) public virtual onlyRole(TOKEN_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_baseUri`|`string`|URI to the metadata file(s) for the contract|


### safeMint

Add appAdministratorOnly modifier to restrict minting privilages
Function is payable for child contracts to override with priced mint function.

*Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.*


```solidity
function safeMint(address to) public payable virtual onlyRole(TOKEN_ADMIN_ROLE);
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
    nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`tokenId`|`uint256`|Id of token to be transferred|
|`batchSize`|`uint256`|the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will represent the first id to start the batch.|


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
    override(AccessControl, ERC721, ERC721Enumerable)
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


### connectHandlerToToken

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


### withdraw

*Function to withdraw Ether sent to contract*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function withdraw() public payable virtual onlyRole(TOKEN_ADMIN_ROLE);
```

