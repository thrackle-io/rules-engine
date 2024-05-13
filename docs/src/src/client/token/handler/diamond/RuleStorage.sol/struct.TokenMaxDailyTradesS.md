# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/aa84a9fbaba8b03f46b7a3b0774885dc91a06fa5/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

