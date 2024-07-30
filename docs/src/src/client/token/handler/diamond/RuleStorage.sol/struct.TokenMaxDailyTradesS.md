# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/0c22edbee3ca4c32dcba8042eeb10bc1a6c3bdd0/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

