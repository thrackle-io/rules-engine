# AccountMaxTradeSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/3af53b224777c5c1f4e2e734b7757bd798236667/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxTradeSizeS {
    mapping(ActionTypes => Rule) accountMaxTradeSize;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

