# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/8f8cd9f0e8cf797290e5a764c49efd646c572381/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

