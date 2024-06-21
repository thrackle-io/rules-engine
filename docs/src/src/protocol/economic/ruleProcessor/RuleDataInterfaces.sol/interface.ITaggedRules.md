# ITaggedRules
[Git Source](https://github.com/thrackle-io/tron/blob/873b14e2bfb8e3c0ec1e8bf0bb215076bd1e60ce/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


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

