# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/12b8f8795779c791ed3113763e21492860614b51/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

