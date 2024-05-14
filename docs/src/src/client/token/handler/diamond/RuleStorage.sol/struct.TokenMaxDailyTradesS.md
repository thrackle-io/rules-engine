# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/1ba87bf9bb403411ce677f8e83126c3bf8cfa713/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

