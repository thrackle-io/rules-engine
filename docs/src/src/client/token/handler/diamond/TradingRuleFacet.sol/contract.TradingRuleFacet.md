# TradingRuleFacet
[Git Source](https://github.com/thrackle-io/tron/blob/3af53b224777c5c1f4e2e734b7757bd798236667/src/client/token/handler/diamond/TradingRuleFacet.sol)

**Inherits:**
[HandlerAccountMaxTradeSize](/src/client/token/handler/ruleContracts/HandlerAccountMaxTradeSize.sol/contract.HandlerAccountMaxTradeSize.md), [HandlerTokenMaxBuySellVolume](/src/client/token/handler/ruleContracts/HandlerTokenMaxBuySellVolume.sol/contract.HandlerTokenMaxBuySellVolume.md)


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


