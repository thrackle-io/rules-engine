# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/35220e3468902ae927d760ed6963ae4507446c20/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

