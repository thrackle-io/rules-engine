# AccountMaxTradeSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/edf3093a9fed22d64a8edbc89ae73bfbadfe2a42/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxTradeSizeS {
    mapping(ActionTypes => Rule) accountMaxTradeSize;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

