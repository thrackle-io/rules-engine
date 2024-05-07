# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/13349942d6b36cb5b881624be044b28167a194cf/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
}
```

