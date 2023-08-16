# INonTaggedRules
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/economic/ruleStorage/RuleDataInterfaces.sol)

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
    uint16 purchasePeriod;
    uint256 totalSupply;
    uint64 startTime;
}
```

### TokenPercentageSellRule
******** Token Percentage Sell Rules ********


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

### TokenVolatilityRule
******** Token Volatility ********


```solidity
struct TokenVolatilityRule {
    uint16 maxVolatility;
    uint16 period;
    uint16 hoursFrozen;
    uint256 totalSupply;
}
```

### TokenTransferVolumeRule
******** Token Transfer Volume ********


```solidity
struct TokenTransferVolumeRule {
    uint24 maxVolume;
    uint16 period;
    uint64 startTime;
    uint256 totalSupply;
}
```

### SupplyVolatilityRule
******** Supply Volatility ********


```solidity
struct SupplyVolatilityRule {
    uint16 maxChange;
    uint16 period;
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
    uint64 startTs;
}
```

