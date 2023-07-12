# INonTaggedRules
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/1967bc8c4a91d28c4a17e06555cea67921b90fa3/src/economic/ruleStorage/RuleDataInterfaces.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*data structures of each rule in the protocol, grouped by rule subset
(NonTagged Rules, Tagged rules, AccessLevel rules, Risk rules, and Fee rules)*


## Structs
### TokenMinimumTransferRule
******** Token Minimum Transfer Rules ********


```solidity
struct TokenMinimumTransferRule {
    uint256 minTransferAmount;
}
```

### TokenPercentagePurchaseRule
******** Token Purchase Percentage Rules ********


```solidity
struct TokenPercentagePurchaseRule {
    uint16 tokenPercentage;
    uint32 purchasePeriod;
    uint256 totalSupply;
    uint64 startTime;
}
```

### TokenPercentageSellRule
******** Token Percentage Sell Rules ********


```solidity
struct TokenPercentageSellRule {
    uint16 tokenPercentage;
    uint32 sellPeriod;
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

### TokenVolatilityRule
******** Token Volatility ********


```solidity
struct TokenVolatilityRule {
    uint16 maxVolatility;
    uint8 period;
    uint64 startingTime;
    uint256 totalSupply;
}
```

### TokenTradingVolumeRule
******** Token Trading Volume ********


```solidity
struct TokenTradingVolumeRule {
    uint256 maxVolume;
    uint8 hoursPerPeriod;
    uint8 hoursFrozen;
}
```

### TokenTransferVolumeRule
******** Token Transfer Volume ********


```solidity
struct TokenTransferVolumeRule {
    uint16 maxVolume;
    uint8 period;
    uint64 startingTime;
    uint256 totalSupply;
}
```

### SupplyVolatilityRule
******** Supply Volatility ********


```solidity
struct SupplyVolatilityRule {
    uint16 maxChange;
    uint8 period;
    uint64 startingTime;
    uint256 totalSupply;
}
```

### OracleRule
******** Oracle ********


```solidity
struct OracleRule {
    uint8 oracleType;
    address oracleAddress;
}
```

### NFTTradeCounterRule
******** NFT ********


```solidity
struct NFTTradeCounterRule {
    uint8 tradesAllowedPerDay;
    bool active;
}
```

