# ProtocolERC20
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/32fc908f43bfbb804e52e049074d30ce661a637a/src/token/ProtocolERC20.sol)

**Inherits:**
ERC20, ERC165, ERC20Burnable, ERC20FlashMint, Pausable, [ProtocolTokenCommon](/src/token/ProtocolTokenCommon.sol/abstract.ProtocolTokenCommon.md), [IProtocolERC20Errors](/src/interfaces/IErrors.sol/interface.IProtocolERC20Errors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC20s

*The only thing to recognize is that flash minting is added but not allowed...yet*


## State Variables
### handler

```solidity
ProtocolERC20Handler handler;
```


### MAX_SUPPLY
Max supply should only be set once. Zero means infinite supply.


```solidity
uint256 MAX_SUPPLY;
```


## Functions
### constructor

*Constructor sets name and symbol for the ERC20 token and makes connections to the protocol.*


```solidity
constructor(string memory _name, string memory _symbol, address _appManagerAddress) ERC20(_name, _symbol);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|name of token|
|`_symbol`|`string`|abreviated name for token (i.e. THRK)|
|`_appManagerAddress`|`address`|address of app manager contract _upgradeMode is also passed to Handler contract to deploy a new data contract with the handler.|


### pause

*pauses the contract. Only whenPaused modified functions will work once called.*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function pause() public virtual appAdministratorOnly(appManagerAddress);
```

### unpause

*Unpause the contract. Only whenNotPaused modified functions will work once called. default state of contract is unpaused.*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function unpause() public virtual appAdministratorOnly(appManagerAddress);
```

### _beforeTokenTransfer

*Function called before any token transfers to confirm transfer is within rules of the protocol*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`amount`|`uint256`|number of tokens to be transferred|


### supportsInterface

Rule Processor Module Check

*See {IERC165-supportsInterface}.*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```

### transfer

*This is overridden from {IERC20-transfer}. It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
Requirements:
- `to` cannot be the zero address.
- the caller must have a balance of at least `amount`.*


```solidity
function transfer(address to, uint256 amount) public virtual override returns (bool);
```

### transferFrom

*This is overridden from {IERC20-transferFrom}. It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
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
function transferFrom(address from, address to, uint256 amount) public override returns (bool);
```

### mint

*Function mints new tokens. AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function mint(address to, uint256 amount) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|recipient address|
|`amount`|`uint256`|number of tokens to mint|


### flashLoan

check that the address calling mint is authorized(appAdminstrator, AMM or Staking Contract)

*This function is overridden here as a guarantee that flashloans are not allowed. This is done in case they are enabled at a later time.*


```solidity
function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data)
    public
    pure
    virtual
    override
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`IERC3156FlashBorrower`|loan recipient.|
|`token`|`address`|address of token calling function|
|`amount`|`uint256`|number of tokens|
|`data`|`bytes`|arbitrary data structure for user params|


### connectHandlerToToken

These are simply to get rid of the compiler warnings.

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _handlerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_handlerAddress`|`address`|address of the currently deployed Handler Address|


### getHandlerAddress

*this function returns the handler address*


```solidity
function getHandlerAddress() external view override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


