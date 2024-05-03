# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/90c179d4a2d3d05eb80cb7a50ea4891339d7488e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
}
```

