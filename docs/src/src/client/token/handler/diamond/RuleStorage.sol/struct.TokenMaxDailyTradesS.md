# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/1f87ef51d3f81854db8d1b233a920d59919e0ac3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
    uint256 ruleChangeDate;
}
```

