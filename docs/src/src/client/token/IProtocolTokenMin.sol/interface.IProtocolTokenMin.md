# IProtocolTokenMin
[Git Source](https://github.com/thrackle-io/tron/blob/5bfb84a51be01d9a959b76979e9b34e41875da67/src/client/token/IProtocolTokenMin.sol)

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


