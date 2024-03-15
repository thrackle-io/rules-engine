# TradingRuleFacet
[Git Source](https://github.com/thrackle-io/tron/blob/5605c9510d83af8a1b2bbbbbe9ac058b9e276ba7/src/client/token/handler/diamond/TradingRuleFacet.sol)

**Inherits:**
[HandlerAccountMaxBuySize](/src/client/token/handler/ruleContracts/HandlerAccountMaxBuySize.sol/contract.HandlerAccountMaxBuySize.md), [HandlerTokenMaxBuyVolume](/src/client/token/handler/ruleContracts/HandlerTokenMaxBuyVolume.sol/contract.HandlerTokenMaxBuyVolume.md), [HandlerAccountMaxSellSize](/src/client/token/handler/ruleContracts/HandlerAccountMaxSellSize.sol/contract.HandlerAccountMaxSellSize.md), [HandlerTokenMaxSellVolume](/src/client/token/handler/ruleContracts/HandlerTokenMaxSellVolume.sol/contract.HandlerTokenMaxSellVolume.md)


## Functions
### checkTradingRules

*This function consolidates all the trading rules.*


```solidity
function checkTradingRules(
    address _from,
    address _to,
    bytes32[] memory fromTags,
    bytes32[] memory toTags,
    uint256 _amount,
    ActionTypes action
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`fromTags`|`bytes32[]`|tags of the from account|
|`toTags`|`bytes32[]`|tags of the from account|
|`_amount`|`uint256`|number of tokens transferred|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|


