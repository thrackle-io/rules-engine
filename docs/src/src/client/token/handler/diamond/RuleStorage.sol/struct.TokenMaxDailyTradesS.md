# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/38ad28ed586c360d4509e485bd378da51297351d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
}
```

