# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/67919752074a6ad99319926c762bce79963a8aa4/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

