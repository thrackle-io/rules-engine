# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/d4dc3a1319e6df3195618c1297a6c755d61cf319/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

