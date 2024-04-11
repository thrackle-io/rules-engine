# TradingRuleFacet
[Git Source](https://github.com/thrackle-io/tron/blob/22d59d8913fec75ff35111960d6c2b98915a9f8b/src/client/token/handler/diamond/TradingRuleFacet.sol)

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


