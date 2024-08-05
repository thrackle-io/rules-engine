# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/3646d7220ca1c3c6e396c1c58012716f59073c50/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

