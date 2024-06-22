# ApplicationERC20
[Git Source](https://github.com/thrackle-io/tron/blob/de69f371f7fd94a0b22f5a213d7ab3968548d9bf/src/example/ERC20/ApplicationERC20.sol)

**Inherits:**
ERC20, AccessControl, [IProtocolToken](/src/client/token/IProtocolToken.sol/interface.IProtocolToken.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

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


### handler

```solidity
IProtocolTokenHandler private handler;
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
|`_tokenAdmin`|`address`|Token Manager address|


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


### _beforeTokenTransfer

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

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


