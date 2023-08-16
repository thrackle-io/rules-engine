# IProtocolERC721Handler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/token/IProtocolERC721Handler.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*This interface provides the ABI for assets to access their handlers in an efficient way*


## Functions
### checkAllRules

*This function is the one called from the contract that implements this handler. It's the entry point to protocol.*


```solidity
function checkAllRules(
    uint256 balanceFrom,
    uint256 balanceTo,
    address _from,
    address _to,
    uint256 amount,
    uint256 _tokenId,
    ActionTypes _action
) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|token balance of sender address|
|`balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|sender address|
|`_to`|`address`|recipient address|
|`amount`|`uint256`|number of tokens transferred|
|`_tokenId`|`uint256`|the token's specific ID|
|`_action`|`ActionTypes`|Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true if all checks pass|


