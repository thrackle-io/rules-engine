# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0775549ba2fe667ec66be14a19fcc8b784774a43/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

