# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/570e509b7dae1b89ffe858956bb3df9bbac2510a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
}
```

