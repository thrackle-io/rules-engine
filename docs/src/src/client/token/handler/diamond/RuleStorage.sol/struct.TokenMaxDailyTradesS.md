# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/5b7fc1e99a9efe7cd4509a3bd8aa91769d651104/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

