# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/362ca5d8826deeb3c732b79b0826e739dff4e241/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
}
```

