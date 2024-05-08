# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/0336bb34620bb9e55e13cd371f0aebd8997d21c3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
}
```

