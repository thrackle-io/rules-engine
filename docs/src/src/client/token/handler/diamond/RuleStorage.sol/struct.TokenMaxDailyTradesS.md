# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/13105ed31bc78c8d50cdf97173deb83a68e88dee/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

