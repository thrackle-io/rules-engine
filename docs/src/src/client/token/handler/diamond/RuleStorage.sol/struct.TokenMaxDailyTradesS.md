# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/f3f89426d30f93406f5ff447f7284dbf958844b4/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

