# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/977acada486f4d8e6eb8170b55a9be84cb27aa08/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

