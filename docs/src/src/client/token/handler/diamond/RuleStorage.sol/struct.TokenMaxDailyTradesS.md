# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/50727ee9211084f05b8690e3435981873338f44e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

