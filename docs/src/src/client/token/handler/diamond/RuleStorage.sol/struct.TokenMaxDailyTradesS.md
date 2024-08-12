# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/47aa0c8585077f5b931483a9b3097e3fe330a3c3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

