# ApplicationERC20
[Git Source](https://github.com/thrackle-io/rules-engine/blob/1f87ef51d3f81854db8d1b233a920d59919e0ac3/src/example/ERC20/ApplicationERC20.sol)

**Inherits:**
ERC20, ERC20Burnable, AccessControl, [IProtocolToken](/src/client/token/IProtocolToken.sol/interface.IProtocolToken.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), ReentrancyGuard, [ITokenEvents](/src/common/IEvents.sol/interface.ITokenEvents.md), [IApplicationEvents](/src/common/IEvents.sol/interface.IApplicationEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4

This is an example implementation that App Devs should use.

*During deployment _tokenName _tokenSymbol _tokenAdmin are set in constructor*


## State Variables
### TOKEN_ADMIN_ROLE

```solidity
bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");
```


### handlerAddress

```solidity
address private handlerAddress;
```


## Functions
### constructor

*Constructor sets params*


```solidity
constructor(string memory _name, string memory _symbol, address _tokenAdmin) ERC20(_name, _symbol);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of the token|
|`_symbol`|`string`|Symbol of the token|
|`_tokenAdmin`|`address`|Token Admin address|


### mint

*Function mints new tokens.*


```solidity
function mint(address to, uint256 amount) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|recipient address|
|`amount`|`uint256`|number of tokens to mint|


### transfer

TRANSFER FUNCTION GROUP START

*This is overridden from [IERC20-transfer](/lib/forge-std/src/mocks/MockERC20.sol/contract.MockERC20.md#transfer). It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
Requirements:
- `to` cannot be the zero address.
- the caller must have a balance of at least `amount`.*


```solidity
function transfer(address to, uint256 amount) public virtual override nonReentrant returns (bool);
```

### transferFrom

*This is overridden from [IERC20-transferFrom](/lib/forge-std/src/mocks/MockERC721.sol/contract.MockERC721.md#transferfrom). It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
Emits an {Approval} event indicating the updated allowance. This is not
required by the EIP. See the note at the beginning of {ERC20}.
NOTE: Does not update the allowance if the current allowance
is the maximum `uint256`.
Requirements:
- `from` and `to` cannot be the zero address.
- `from` must have a balance of at least `amount`.
- the caller must have allowance for ``from``'s tokens of at least
`amount`.*


```solidity
function transferFrom(address from, address to, uint256 amount) public override nonReentrant returns (bool);
```

### _handleFees

*This transfers all the P2P transfer fees to the individual fee sinks*


```solidity
function _handleFees(address from, uint256 amount) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`amount`|`uint256`|number of tokens being transferred|


### _beforeTokenTransfer

TRANSFER FUNCTION GROUP END

*Function called before any token transfers to confirm transfer is within rules of the protocol*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`amount`|`uint256`|number of tokens to be transferred|


### getHandlerAddress

Rule Processor Module Check

*This function returns the handler address*


```solidity
function getHandlerAddress() external view override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


### connectHandlerToToken

This function does not check for zero address. Zero address is a valid address for this function's purpose.

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


