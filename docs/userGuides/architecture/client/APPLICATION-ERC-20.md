# Application ERC 20

## Purpose

The Application ERC 20 defines the base that contracts must conform to in order to be compatible with the protocol. Using the Application ERC 20 does not restrict you from inheriting from other internal or external contracts, such as other OpenZeppelin contracts or custom logic contracts specific to your application. 
## Structure

The Application ERC 20 inherits from multiple contracts (internal and external), overrides functions from some of the inherited contracts, and defines a few functions of its own. The following contracts are inherited:
- ERC20 (external to the protocol)
- AccessControl (external to the protocol)
- IProtocolToken (internal to the protocol)
- IProtocolTokenHandler (internal to the protocol)
- IZeroAddressError from IErrors (internal to the protocol)

### Function Overrides 

The following functions are overridden from the inherited versions to add protocol specific logic:

- _beforeTokenTransfer: overridden to allow protocol rule check hook.

```c
  function _beforeTokenTransfer(address from, address to, uint256 amount) internal override
```
- transferFrom: overridden to allow fee processing
```c
  function transferFrom(address from, address to, uint256 amount) public override nonReentrant returns (bool)
```
- transfer: overridden to allow fee processing
```c
  function transfer(address to, uint256 amount) public virtual override nonReentrant returns (bool)
```

### Added Functions
The following functions have been added specifically to the ApplicationERC20 contract:
- connectHandlerToToken: Used to connect a deployed Protocol Token Handler to the token.

```c
  function connectHandlerToToken(address _handlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE)
```

- getHandlerAddress: used to retrieve the address of the Protocol Token Handler.

```c
  function getHandlerAddress() external view override returns (address)
```
- _handleFees: used to process fees.
```c
  function _handleFees(address from, uint256 amount) internal returns (uint256)
```

### Upgrading The Handler

In order to upgrade a Protocol Supported ERC 20s handler simply call the connectHandlerToToken function with the address of the new handler contract. 