# TokenMaxDailyTradesS
[Git Source](https://github.com/thrackle-io/tron/blob/f0b9409d0746d035136fce54b3907220cf162a23/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxDailyTradesS {
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
}
```

