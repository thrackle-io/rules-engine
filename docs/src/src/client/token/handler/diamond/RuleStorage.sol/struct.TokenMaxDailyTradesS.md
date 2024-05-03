# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/63fcd46f6c4c395f84afa43dab91856da44b1c42/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
    mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
}
```

