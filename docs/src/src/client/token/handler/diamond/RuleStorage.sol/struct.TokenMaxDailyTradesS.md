# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/ce3e124fbb7b1c9745b955077cf9cd260c5eabe5/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

