# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/d5c4da9c910c7f583b74a714399bd64fbb32b616/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

