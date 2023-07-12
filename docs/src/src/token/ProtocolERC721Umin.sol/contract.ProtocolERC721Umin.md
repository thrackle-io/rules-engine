# ProtocolERC721Umin
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/2eb992c5f8a67ecb6f7fb3675bc386aaa483c728/src/token/ProtocolERC721Umin.sol)

**Inherits:**
Initializable, [AppAdministratorOnlyU](/src/economic/AppAdministratorOnlyU.sol/contract.AppAdministratorOnlyU.md), [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md), [IZeroAddressError](/src/interfaces/IErrors.sol/interface.IZeroAddressError.md), ERC721EnumerableUpgradeable

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC721Upgradeables


## State Variables
### appManagerAddress

```solidity
address private appManagerAddress;
```


### handlerAddress

```solidity
address private handlerAddress;
```


### handler

```solidity
IProtocolERC721Handler private handler;
```


### VERSION
keeps track of RULE enum version and other features


```solidity
uint8 private constant VERSION = 1;
```


## Functions
### __ProtocolERC721_init

*Initializer sets the the App Manager*


```solidity
function __ProtocolERC721_init(address _appManagerAddress) internal onlyInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|Address of App Manager|


### __ProtocolERC721_init_unchained


```solidity
function __ProtocolERC721_init_unchained(address _appManagerAddress) internal onlyInitializing;
```

### _beforeTokenTransfer

*Function called before any token transfers to confirm transfer is within rules of the protocol*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`tokenId`|`uint256`|Id of token to be transferred|
|`batchSize`|`uint256`|the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will represent the first id to start the batch.|


### setAppManagerAddress

*Function to set the appManagerAddress*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress);
```

### getAppManagerAddress

*Function to get the appManagerAddress*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function getAppManagerAddress() external view returns (address);
```

### getHandlerAddress

*this function returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


### connectHandlerToToken

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


