# INonTaggedRules
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*data structures of each rule in the protocol, grouped by rule subset
(NonTagged Rules, Tagged rules, AccessLevel rules, Risk rules, and Fee rules)*


## Structs
### TokenMinimumTransferRule
******** Token Minimum Transfer Rules ********


```solidity
struct TokenMinimumTransferRule {
    uint256 minSize;
}
```

### TokenMaxBuyVolume
******** Token Max Buy Volume ********


```solidity
struct TokenMaxBuyVolume {
    uint16 tokenPercentage;
    uint16 period;
    uint256 totalSupply;
    uint64 startTime;
}
```

### TokenPercentageSellRule
******** Token Max Sell Volume Rules ********


```solidity
struct TokenPercentageSellRule {
    uint16 tokenPercentage;
    uint16 sellPeriod;
    uint256 totalSupply;
    uint64 startTime;
}
```

### TokenPurchaseFeeByVolume
******** Token Purchase Fee By Volume Rules ********


```solidity
struct TokenPurchaseFeeByVolume {
    uint256 volume;
    uint16 rateIncreased;
}
```

### TokenMaxPriceVolatility
******** Token Volatility ********


```solidity
struct TokenMaxPriceVolatility {
    uint16 max;
    uint16 period;
    uint16 hoursFrozen;
    uint256 totalSupply;
}
```

### TokenMaxTradingVolume
******** Token Transfer Volume ********


```solidity
struct TokenMaxTradingVolume {
    uint24 max;
    uint16 period;
    uint64 startTime;
    uint256 totalSupply;
}
```

### SupplyVolatilityRule
******** Supply Volatility ********


```solidity
struct SupplyVolatilityRule {
    uint16 max;
    uint16 period;
    uint64 startingTime;
    uint256 totalSupply;
}
```

### AccountApproveDenyOracle
******** Oracle ********


```solidity
struct AccountApproveDenyOracle {
    uint8 oracleType;
    address oracleAddress;
}
```

