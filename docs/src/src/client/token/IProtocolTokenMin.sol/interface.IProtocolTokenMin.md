# IProtocolTokenMin
[Git Source](https://github.com/thrackle-io/tron/blob/192018a749cd70c7df311296c3236b79e11af0f3/src/client/token/IProtocolTokenMin.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett, mpetersoCode55

This is the base contract for all protocol ERC20s

*Using this interface requires the implementing token properly handle the listed functions as well as insert the checkAllRules hook into _beforeTokenTransfer*


## Functions
### connectHandlerToToken

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _handlerAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_handlerAddress`|`address`|address of the currently deployed Handler Address|


### getHandlerAddress

*This function returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


