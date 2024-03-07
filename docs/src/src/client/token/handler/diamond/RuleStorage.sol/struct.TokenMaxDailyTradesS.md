# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/46cb5e729fbe3c8dc7b7ecacae59ec49544d86f9/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

