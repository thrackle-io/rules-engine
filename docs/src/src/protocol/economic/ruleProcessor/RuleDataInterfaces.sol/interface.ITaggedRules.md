# ITaggedRules
[Git Source](https://github.com/thrackle-io/tron/blob/b7e3c80b9894bc0c1005dc8b0adb631c487f2598/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


## Structs
### AccountMaxBuySize
******** Account Max Buy Volume ********


```solidity
struct AccountMaxBuySize {
    uint256 maxSize;
    uint16 period;
}
```

### AccountMaxSellSize
******** Account Max Sell Size ********


```solidity
struct AccountMaxSellSize {
    uint256 maxSize;
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

