# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/5b4c46cba4728d833e07b42f737a689087f379aa/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

