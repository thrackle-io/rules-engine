# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/4f1430717249c90fcbde9d9572fe2ac92dc2c5d4/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

