# IProtocolERC20UMin
[Git Source](https://github.com/thrackle-io/tron/blob/f3bd6a25d2a231a2f0551b95491d3fdfe01415dc/src/client/token/ERC20/upgradeable/IProtocolERC20UMin.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC20Upgradeables

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
### AD1467_HandlerConnected

```solidity
event AD1467_HandlerConnected(address indexed handlerAddress, address indexed assetAddress);
```

## Errors
### ZeroAddress

```solidity
error ZeroAddress();
```

