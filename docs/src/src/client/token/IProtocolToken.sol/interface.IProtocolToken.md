# IProtocolToken
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0775549ba2fe667ec66be14a19fcc8b784774a43/src/client/token/IProtocolToken.sol)

**Inherits:**
[IIntegrationEvents](/src/common/IEvents.sol/interface.IIntegrationEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4

This is the base contract for all protocol tokens

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


