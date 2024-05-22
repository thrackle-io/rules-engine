# IProtocolERC721UMin
[Git Source](https://github.com/thrackle-io/tron/blob/02db7a0f302d98149458dfe5cd5a62ffb6f478a7/src/client/token/ERC721/upgradeable/IProtocolERC721UMin.sol)

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

