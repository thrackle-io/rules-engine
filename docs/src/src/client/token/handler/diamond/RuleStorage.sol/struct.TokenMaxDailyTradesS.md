# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/f7f6e3590faaa9c8f0fe0115492201b8f8dd1711/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

