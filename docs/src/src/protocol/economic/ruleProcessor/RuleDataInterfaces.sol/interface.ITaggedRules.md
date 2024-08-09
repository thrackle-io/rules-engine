# ITaggedRules
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/00cdc21330585fccf9dc326a2f7aeba02706eb37/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


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

