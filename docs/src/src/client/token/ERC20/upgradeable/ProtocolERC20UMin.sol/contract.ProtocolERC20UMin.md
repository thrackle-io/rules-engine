# ProtocolERC20UMin
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/5b4c46cba4728d833e07b42f737a689087f379aa/src/client/token/ERC20/upgradeable/ProtocolERC20UMin.sol)

**Inherits:**
Initializable, ERC20Upgradeable, [ProtocolTokenCommonU](/src/client/token/ProtocolTokenCommonU.sol/abstract.ProtocolTokenCommonU.md), ReentrancyGuard

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4

This is the base contract for all protocol ERC721Upgradeable Minimals.


## State Variables
### handlerAddress

```solidity
address private handlerAddress;
```


### handler

```solidity
IProtocolTokenHandler private handler;
```


### __gap
memory placeholders to allow variable addition without affecting client upgradeability


```solidity
uint256[49] __gap;
```


## Functions
### __ProtocolERC20_init

*Initializer sets the the App Manager*


```solidity
function __ProtocolERC20_init(address _appManagerAddress) internal onlyInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|Address of App Manager|


### __ProtocolERC20_init_unchained


```solidity
function __ProtocolERC20_init_unchained(address _appManagerAddress) internal onlyInitializing;
```

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
function connectHandlerToToken(address _deployedHandlerAddress)
    external
    override
    appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


