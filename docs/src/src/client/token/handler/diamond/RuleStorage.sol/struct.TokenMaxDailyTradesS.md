# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/759037970009f24ec0ac5995bf26019f0b6997be/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

