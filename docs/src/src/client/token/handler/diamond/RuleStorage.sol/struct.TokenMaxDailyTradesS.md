# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/a0e7b20980bb06404eb010a144cfad3764962831/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

