# ITaggedRules
[Git Source](https://github.com/thrackle-io/tron/blob/29c0f577f4a40a4ed7ae1702ee35ca11ff1ccfaf/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


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

### AdminMinTokenBalance
******** Admin Min Token Balance ********


```solidity
struct AdminMinTokenBalance {
    uint256 amount;
    uint256 endTime;
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

