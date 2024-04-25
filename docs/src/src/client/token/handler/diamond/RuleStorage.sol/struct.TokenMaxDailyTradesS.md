# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/81b80009ad5682c206d626e3be15fff689d615e0/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

