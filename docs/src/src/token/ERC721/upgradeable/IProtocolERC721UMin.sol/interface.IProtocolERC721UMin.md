# IProtocolERC721UMin
<<<<<<< HEAD:docs/src/src/token/IProtocolERC721UMin.sol/interface.IProtocolERC721UMin.md
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/token/IProtocolERC721UMin.sol)
=======
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/token/ERC721/upgradeable/IProtocolERC721UMin.sol)
>>>>>>> external:docs/src/src/token/ERC721/upgradeable/IProtocolERC721UMin.sol/interface.IProtocolERC721UMin.md

**Inherits:**
IERC721EnumerableUpgradeable

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC721Upgradeables

*Using this interface requires the implementing token properly handle the listed functions as well as insert the checkAllRules hook into _beforeTokenTransfer*


## Functions
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
function connectHandlerToToken(address _deployedHandlerAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


## Events
### HandlerConnected

```solidity
event HandlerConnected(address indexed handlerAddress, address indexed assetAddress);
```

## Errors
### ZeroAddress

```solidity
error ZeroAddress();
```

