# AccountMaxTradeSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/f7f6e3590faaa9c8f0fe0115492201b8f8dd1711/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxTradeSizeS {
    mapping(ActionTypes => Rule) accountMaxTradeSize;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

