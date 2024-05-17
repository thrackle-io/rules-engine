# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/f3bd6a25d2a231a2f0551b95491d3fdfe01415dc/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

