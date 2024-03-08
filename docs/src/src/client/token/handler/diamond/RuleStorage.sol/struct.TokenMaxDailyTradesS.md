# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/baac0bbfdefb8a299b09493a3979f2ef5c07be0f/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

