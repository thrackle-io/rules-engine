# Protocol ERC 20

## Purpose

The Protocol ERC 20 defines the base that contracts must conform to in order to be compatible with the protocol.

## Structure

The Protocol ERC 20 inherits from multiple contracts (internal and external), overrides functions from some of the inherited contracts, and defines a few functions of its own. The following contracts are inherited:
- ERC20 (external to the protocol)
- ERC165 (external to the protocol)
- EC20Burnable (external to the protocol)
- ERC20FlashMint (external to the protocol)
- Pausable (external to the protocol)
- ProtocolTokenCommon (internal to the protocol)
- IProtocolERX20Errors (internal to the protocol)

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

- _beforeTokenTransfer: overridden to allow protocol rule check hook.

```c
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused
```

- supportsInterface: overridden to explicitly add IERC20 to the supported list.

```c
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) 
```

- transfer: overridden to apply protocol fees.

```c
function transfer(address to, uint256 amount) public virtual override returns (bool)
```

- transferFrom: overridden to apply protocol fees.

```c
function transferFrom(address from, address to, uint256 amount) public override returns (bool)
```

- mint: overridden to apply additional caller constraints (can only be called by an App Admin) and verify doesn't exceed the defined max supply.

```c
function mint(address to, uint256 amount) public virtual
```

- flashLoan: overridden to explicitly not allow flashloans.

```c
function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data) public pure virtual override returns (bool)
```

### Added Functions
The following functions have been added specifically to the ProtocolERC20 contract:
- connectHandlerToToken: Used to connect a deployed Protocol Token Handler to the token.

```c
function connectHandlerToToken(address _handlerAddress) external appAdministratorOnly(appManagerAddress)
```

- getHandlerAddress: used to retrieve the address of the Protocol Token Handler.

```c
function getHandlerAddress() external view override returns (address)
```

### Upgrading The Handler

In order to upgrade a Protocol Supported ERC 20s handler simply call the connectHandlerToToken function with the address of the new handler contract. 