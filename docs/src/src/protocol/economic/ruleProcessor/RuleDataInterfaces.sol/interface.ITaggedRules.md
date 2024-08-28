# ITaggedRules
[Git Source](https://github.com/thrackle-io/rules-engine/blob/f3baf971c7cb5a9708b7ed14723c3823c9ae4656/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


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

