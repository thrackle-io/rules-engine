# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/ce8f3ce20cc777375e5a3cbfcde63db2607acc28/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

