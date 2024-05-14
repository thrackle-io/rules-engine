# ITaggedRules
[Git Source](https://github.com/thrackle-io/tron/blob/aa84a9fbaba8b03f46b7a3b0774885dc91a06fa5/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


## Structs
### AccountMaxTradeSize
******** Account Max Trade Size ********


```solidity
struct AccountMaxTradeSize {
    uint240 maxSize;
    uint16 period;
}
```

### AccountMinMaxTokenBalance
******** Account Min Max Token Balance ********


```solidity
struct AccountMinMaxTokenBalance {
    uint256 min;
    uint256 max;
    uint16 period;
}
```

### TokenMaxDailyTrades
******** TokenMaxDailyTrades ********


```solidity
struct TokenMaxDailyTrades {
    uint8 tradesAllowedPerDay;
    uint64 startTime;
}
```

