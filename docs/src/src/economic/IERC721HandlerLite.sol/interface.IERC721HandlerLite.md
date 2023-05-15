# IERC721HandlerLite
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/economic/IERC721HandlerLite.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*the light version of the TokenRuleRouter. This is only used by the NFT contracts that
require tokenId*


## Functions
### checkAllRules

*Check the rules of the Protocol*


```solidity
function checkAllRules(
    uint256 balanceFrom,
    uint256 balanceTo,
    address _from,
    address _to,
    uint256 amount,
    uint256 tokenId,
    ApplicationRuleProcessorDiamondLib.ActionTypes _action
) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`balanceTo`|`uint256`|Token balance of the recipient address|
|`_from`|`address`|Sender address|
|`_to`|`address`|Recipient address|
|`amount`|`uint256`|total number of tokens to be transferred|
|`tokenId`|`uint256`|Id of token|
|`_action`|`ApplicationRuleProcessorDiamondLib.ActionTypes`|Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true and Failure equals false|


### setERC721Address

*Set the parent ERC721 address*


```solidity
function setERC721Address(address _address) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the ERC721|


