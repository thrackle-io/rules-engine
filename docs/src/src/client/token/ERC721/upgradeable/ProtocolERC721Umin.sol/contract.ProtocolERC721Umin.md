# ProtocolERC721Umin
[Git Source](https://github.com/thrackle-io/tron/blob/29c2cd95da29b0356348370e1ddb4d7bdc24a711/src/client/token/ERC721/upgradeable/ProtocolERC721Umin.sol)

**Inherits:**
Initializable, ERC721EnumerableUpgradeable, [ProtocolTokenCommonU](/src/client/token/ProtocolTokenCommonU.sol/contract.ProtocolTokenCommonU.md), ReentrancyGuard

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

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
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
    internal
    virtual
    override
    nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`tokenId`|`uint256`|Id of token to be transferred|
|`batchSize`|`uint256`|the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will represent the first id to start the batch.|


### getHandlerAddress

Rule Processor Module Check

*This function returns the handler address*


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


