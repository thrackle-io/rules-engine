# ProtocolERC20
[Git Source](https://github.com/thrackle-io/Tron/blob/89e7f7b48d79c8e2bc6476fb1601cc9680f2c384/src/token/ProtocolERC20.sol)

**Inherits:**
ERC20, ERC165, ERC20Burnable, ERC20FlashMint, Pausable, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC20s

*The only thing to recognize is that flash minting is added but not allowed...yet*


## State Variables
### appManagerAddress

```solidity
address public appManagerAddress;
```


### handlerAddress

```solidity
address handlerAddress;
```


### handler

```solidity
ProtocolERC20Handler handler;
```


### appManager

```solidity
IAppManager appManager;
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
constructor(
    string memory _name,
    string memory _symbol,
    address _appManagerAddress,
    address _ruleProcessor,
    bool _upgradeMode
) ERC20(_name, _symbol);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|name of token|
|`_symbol`|`string`|abreviated name for token (i.e. THRK)|
|`_appManagerAddress`|`address`|address of app manager contract|
|`_ruleProcessor`|`address`|Address of the protocol rule processor|
|`_upgradeMode`|`bool`|token deploys a Handler contract, false = handler deployed, true = upgraded token contract and no handler. _upgradeMode is also passed to Handler contract to deploy a new data contract with the handler.|


### pause

Only deploy a new handler if this isn't an upgrade

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


### deployHandler

These are simply to get rid of the compiler warnings.

*This function is called at deployment in the constructor to deploy the Handler Contract for the Token.*


```solidity
function deployHandler(address _ruleProcessor, address _appManagerAddress, bool _upgradeMode)
    private
    returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessor`|`address`|address of the rule processor|
|`_appManagerAddress`|`address`|address of the Application Manager Contract|
|`_upgradeMode`|`bool`|bool representing if this contract will deploy data contracts or if this is an upgrade|

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


### getHandlerAddress

*this function returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


## Errors
### ExceedingMaxSupply

```solidity
error ExceedingMaxSupply();
```

### CallerNotAuthorizedToMint

```solidity
error CallerNotAuthorizedToMint();
```

### ZeroAddress

```solidity
error ZeroAddress();
```

