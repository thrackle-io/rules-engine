# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/8f688cb5e6148d0b374ef77b936d7812ad0892e1/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

