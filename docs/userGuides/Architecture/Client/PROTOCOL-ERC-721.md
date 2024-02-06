# Protocol ERC 721

## Purpose

The Protocol ERC 721 defines the base that contracts must conform to in order to be compatible with the protocol.

## Structure

The Protocol ERC 721 inherits from multiple contracts (internal and external), overrides functions from some of the inherited contracts, and defines a few functions of its own. The following contracts are inherited:
- ERC721Burnable (external to the protocol)
- ERC721URIStorage (external to the protocol)
- ERC721Enumerable (external to the protocol)
- Pauable (external to the protocol)
- ProtocolTokenCommon (internal to the protocol)
- AppAdministratorOrOwnerOnly (internal to the protocol)

### Function Overrides 

The following functions are overridden from the inherited versions to add protocol specific logic:
- pause: overridden to apply additional caller constraints (can only be called by an App Admin).

```c
function pause() public virtual appAdministratorOnly(appManagerAddress)
```

- unpause: overridden to apply additional caller constraints (can only be called by an App Admin).

```c
function unpause() public virtual appAdministratorOnly(appManagerAddress)
```

- safeMint: overridden to increment the internal tokenIdCounter, only allow when not paused and to apply additional caller constraints (can only be called by an App Admin).

```c
function safeMint(address to) public payable virtual whenNotPaused appAdministratorOrOwnerOnly(appManagerAddress)
```

- _beforeTokenTransfer: overridden to allow protocol rule check hook.

```c
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable) whenNotPaused
```

- _burn: overridden to only allow when not paused.

```c
function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) whenNotPaused
```

- withdraw: overridden to apply additional caller constraints (can only be called by an App Admin).

```c
function withdraw() public payable virtual appAdministratorOnly(appManagerAddress)
```

- supportsInterface: overridden to explicitly add ERC721Enumerable and ERC721URIStorage to the supported list.

```c
function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage) returns (bool)
```

### Added Functions
The following functions have been added specifically to the ProtocolERC721 contract:
- connectHandlerToToken: Used to connect a deployed Protocol Token Handler to the token.

```c
function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress)
```

- getHandlerAddress: used to retrieve the address of the Protocol Token Handler.

```c
function getHandlerAddress() external view override returns (address)
```

- setBaseURI: used to set the URI for the contract.

```c
function setBaseURI(string memory _baseUri) public virtual appAdministratorOnly(appManagerAddress)
```

- _baseURI: used to retrieve the URI for the contract.

```c
function _baseURI() internal view override returns (string memory)
```

### Upgrading The Handler

In order to upgrade a Protocol Supported ERC 721s handler simply call the connectHandlerToToken function with the address of the new handler contract. 