# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/1e4e061752cea9c86408a9ccfc7ebc0d0de4bb9a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

