# AccountMaxTradeSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/bb9fb29098b7e62d948f810420d516cd6ca78012/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxTradeSizeS {
    mapping(ActionTypes => Rule) accountMaxTradeSize;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

