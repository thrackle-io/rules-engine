#  Application ERC 721

## Purpose

The Application ERC 721 defines the base that contracts must conform to in order to be compatible with the protocol. Using the Application ERC 721 does not restrict you from inheriting from other internal or external contracts, such as other OpenZeppelin contracts or custom logic contracts specific to your application.

## Structure

The Application ERC 721 inherits from multiple contracts (internal and external), overrides functions from some of the inherited contracts, and defines a few functions of its own. The following contracts are inherited:
- Counters (external to the protocol)
- ERC721 (external to the protocol)
- ReentrancyGuard (external to the protocol)
- AccessControl (external to the protocol)
- ERC721Burnable (eternal to the protocol)
- ERC721Enumerable (external to the protocol)
- IProtocolToken (internal to the protocol)
- IProtocolTokenHandler (internal to the protocol)
- IZeroAddressError from IErrors (internal to the protocol)

### Function Overrides 

The following functions are overridden from the inherited versions to add protocol specific logic:

- safeMint: overridden to increment the internal tokenIdCounter

```c
function safeMint(address to) public payable virtual
```

- _baseURI: used to retrieve the URI for the contract.

```c
function _baseURI() internal view override returns (string memory)
```

- _beforeTokenTransfer: overridden to allow protocol rule check hook.

```c
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal nonReentrant override
```

- connectHandlerToToken: Used to connect a deployed Protocol Token Handler to the token.

```c
function connectHandlerToToken(address _deployedHandlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE)
```

- getHandlerAddress: used to retrieve the address of the Protocol Token Handler.

```c
function getHandlerAddress() external view override returns (address)
```

### Added Functions
The following functions have been added specifically to the ApplicationERC721 contract:

- setBaseURI: used to set the URI for the contract.

```c
function setBaseURI(string memory _baseUri) public virtual onlyRole(TOKEN_ADMIN_ROLE)
```

### Upgrading The Handler

In order to upgrade a Protocol Supported ERC 721s handler simply call the connectHandlerToToken function with the address of the new handler contract. 