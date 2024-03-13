# ERC721NonTaggedRuleFacet
[Git Source](https://github.com/thrackle-io/tron/blob/4b8e6b6f1f58764b58a041110acc182dd905d211/src/client/token/handler/diamond/ERC721NonTaggedRuleFacet.sol)

**Inherits:**
[HandlerAccountApproveDenyOracle](/src/client/token/handler/ruleContracts/HandlerAccountApproveDenyOracle.sol/contract.HandlerAccountApproveDenyOracle.md), [HandlerTokenMaxSupplyVolatility](/src/client/token/handler/ruleContracts/HandlerTokenMaxSupplyVolatility.sol/contract.HandlerTokenMaxSupplyVolatility.md), [HandlerTokenMaxTradingVolume](/src/client/token/handler/ruleContracts/HandlerTokenMaxTradingVolume.sol/contract.HandlerTokenMaxTradingVolume.md), [HandlerTokenMinTxSize](/src/client/token/handler/ruleContracts/HandlerTokenMinTxSize.sol/contract.HandlerTokenMinTxSize.md), [HandlerTokenMinHoldTime](/src/client/token/handler/ruleContracts/HandlerTokenMinHoldTime.sol/contract.HandlerTokenMinHoldTime.md), [HandlerTokenMaxDailyTrades](/src/client/token/handler/ruleContracts/HandlerTokenMaxDailyTrades.sol/contract.HandlerTokenMaxDailyTrades.md)


## Functions
### checkNonTaggedRules

*This function uses the protocol's ruleProcessorto perform the actual  rule checks.*


```solidity
function checkNonTaggedRules(ActionTypes action, address _from, address _to, uint256 _amount, uint256 _tokenId)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`||
|`_tokenId`|`uint256`|id of the NFT being transferred|


### _checkSimpleRules

rule requires ruleID and either to or from address be zero address (mint/burn)

*This function uses the protocol's ruleProcessor to perform the simple rule checks.(Ones that have simple parameters and so are not stored in the rule storage diamond)*


```solidity
function _checkSimpleRules(ActionTypes _action, uint256 _tokenId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|action to be checked|
|`_tokenId`|`uint256`|the specific token in question|


