# INonTaggedRules
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4e5c0bf97c314267dd6acccac5053bfaa6859607/src/economic/ruleStorage/RuleDataInterfaces.sol)

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
    uint32 hoursFrozen;
}
```

### TokenPercentageSellRule
******** Token Percentage Sell Rules ********


```solidity
struct TokenPercentageSellRule {
    uint16 tokenPercentage;
    uint32 hoursFrozen;
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
    uint8 blocksPerPeriod;
    uint8 hoursFrozen;
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

### SupplyVolatilityRule
******** Supply Volatility ********


```solidity
struct SupplyVolatilityRule {
    uint16 maxChange;
    uint8 hoursPerPeriod;
    uint8 hoursFrozen;
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

