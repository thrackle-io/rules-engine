# AccountMaxTradeSizeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0775549ba2fe667ec66be14a19fcc8b784774a43/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxTradeSizeS {
    mapping(ActionTypes => Rule) accountMaxTradeSize;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
    uint256 ruleChangeDate;
}
```

