# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/57b349a6cc320a1f7ecb037fec845111fdd03ebb/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

