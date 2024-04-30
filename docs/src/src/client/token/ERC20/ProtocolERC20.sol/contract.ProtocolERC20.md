# ProtocolERC20
[Git Source](https://github.com/thrackle-io/tron/blob/fa1f71d854feb4f93c1bbe77dbe731527e9e3d00/src/client/token/ERC20/ProtocolERC20.sol)

**Inherits:**
ERC20, ERC165, ERC20Burnable, ERC20FlashMint, Pausable, [ProtocolTokenCommon](/src/client/token/ProtocolTokenCommon.sol/abstract.ProtocolTokenCommon.md), [IProtocolERC20Errors](/src/common/IErrors.sol/interface.IProtocolERC20Errors.md), ReentrancyGuard

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC20s

*The only thing to recognize is that flash minting is added but not yet allowed.*


## State Variables
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
|`_appManagerAddress`|`address`|address of app manager contract|


### pause

*Pauses the contract. Only whenPaused modified functions will work once called.*

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

*See [IERC165-supportsInterface](/lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/interfaces/IERC165.sol/interface.IERC165.md#supportsinterface).*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```

### transfer

*This is overridden from [IERC20-transfer](/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol/interface.IERC20.md#transfer). It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
Requirements:
- `to` cannot be the zero address.
- the caller must have a balance of at least `amount`.*


```solidity
function transfer(address to, uint256 amount) public virtual override nonReentrant returns (bool);
```

### transferFrom

*This is overridden from [IERC20-transferFrom](/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol/interface.IERC20.md#transferfrom). It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
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

Check that the address calling mint is authorized(appAdminstrator, AMM or Staking Contract)

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


### setMaxSupply

These are simply to get rid of the compiler warnings.

*Function sets the Max Supply for tokens. If left at 0, infinite supply.*


```solidity
function setMaxSupply(uint256 _maxSupply) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_maxSupply`|`uint256`|maximum supply of tokens allowed.|


### getMaxSupply

*Function gets the Max Supply for tokens.*


```solidity
function getMaxSupply() external view returns (uint256);
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


