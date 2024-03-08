# IRuleStorage
[Git Source](https://github.com/thrackle-io/tron/blob/6347e28a06cfe8dcc416f54eea2d35ee6b0ce9fd/src/protocol/economic/ruleProcessor/IRuleStorage.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This interface outlines the storage structures for each rule stored in diamond

*The data structure of each rule storage inside the diamond.*


## Structs
### AccountMaxBuySizeS
Note The following are market-related oppertation rules. Checks depend on the
accuracy of the method to determine when a transfer is part of a trade and what
direction it is taking (buy or sell).
******** Account Max Buy Sizes ********


```solidity
struct AccountMaxBuySizeS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.AccountMaxBuySize)) accountMaxBuySizeRules;
    mapping(uint32 => uint64) startTimes;
    uint32 accountMaxBuySizeIndex;
}
```

### AccountMaxSellSizeS
******** Account Max Sell Sizes ********


```solidity
struct AccountMaxSellSizeS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.AccountMaxSellSize)) AccountMaxSellSizesRules;
    mapping(uint32 => uint64) startTimes;
    uint32 AccountMaxSellSizesIndex;
}
```

### TokenMaxBuyVolumeS
******** Token Max Buy Volume ********


```solidity
struct TokenMaxBuyVolumeS {
    mapping(uint32 => INonTaggedRules.TokenMaxBuyVolume) tokenMaxBuyVolumeRules;
    uint32 tokenMaxBuyVolumeIndex;
}
```

### TokenMaxSellVolumeS
******** Token Max Sell Volume Rules ********


```solidity
struct TokenMaxSellVolumeS {
    mapping(uint32 => INonTaggedRules.TokenMaxSellVolume) tokenMaxSellVolumeRules;
    uint32 tokenMaxSellVolumeIndex;
}
```

### PurchaseFeeByVolRuleS
******** Token Purchase Fee By Volume Rules ********


```solidity
struct PurchaseFeeByVolRuleS {
    mapping(uint32 => INonTaggedRules.TokenPurchaseFeeByVolume) purchaseFeeByVolumeRules;
    uint32 purchaseFeeByVolumeRuleIndex;
}
```

### TokenMaxPriceVolatilityS
******** Token Max Price Volatility ********


```solidity
struct TokenMaxPriceVolatilityS {
    mapping(uint32 => INonTaggedRules.TokenMaxPriceVolatility) tokenMaxPriceVolatilityRules;
    uint32 tokenMaxPriceVolatilityIndex;
}
```

### TokenMaxTradingVolumeS
******** Token Max Trading Volume ********


```solidity
struct TokenMaxTradingVolumeS {
    mapping(uint32 => INonTaggedRules.TokenMaxTradingVolume) tokenMaxTradingVolumeRules;
    uint32 tokenMaxTradingVolumeIndex;
}
```

### AdminMinTokenBalanceS
******** Admin Min Token Balance ********


```solidity
struct AdminMinTokenBalanceS {
    mapping(uint32 => ITaggedRules.AdminMinTokenBalance) adminMinTokenBalanceRules;
    uint32 adminMinTokenBalanceIndex;
}
```

### TokenMinTxSizeS
******** Token Min Tx Size ********


```solidity
struct TokenMinTxSizeS {
    mapping(uint32 => INonTaggedRules.TokenMinTxSize) tokenMinTxSizeRules;
    uint32 tokenMinTxSizeIndex;
}
```

### AccountMinMaxTokenBalanceS
******** Account Minimum/Maximum Token Balance ********


```solidity
struct AccountMinMaxTokenBalanceS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.AccountMinMaxTokenBalance)) accountMinMaxTokenBalanceRules;
    mapping(uint32 => uint64) startTimes;
    uint32 accountMinMaxTokenBalanceIndex;
}
```

### TokenMaxSupplyVolatilityS
******** Token Max Supply Volatility ********


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(uint32 => INonTaggedRules.TokenMaxSupplyVolatility) tokenMaxSupplyVolatilityRules;
    uint32 tokenMaxSupplyVolatilityIndex;
}
```

### AccountApproveDenyOracleS
******** Account Approve/Deny Oracle ********


```solidity
struct AccountApproveDenyOracleS {
    mapping(uint32 => INonTaggedRules.AccountApproveDenyOracle) accountApproveDenyOracleRules;
    uint32 accountApproveDenyOracleIndex;
}
```

### AccountMaxValueByAccessLevelS
AccessLevel Rules ***********
/****************************************
******** Account Max Value by Access Level ********


```solidity
struct AccountMaxValueByAccessLevelS {
    mapping(uint32 => mapping(uint8 => uint48)) accountMaxValueByAccessLevelRules;
    uint32 accountMaxValueByAccessLevelIndex;
}
```

### AccountMaxValueOutByAccessLevelS
******** Account Max Value Out by Access Level ********


```solidity
struct AccountMaxValueOutByAccessLevelS {
    mapping(uint32 => mapping(uint8 => uint48)) accountMaxValueOutByAccessLevelRules;
    uint32 accountMaxValueOutByAccessLevelIndex;
}
```

### TokenMaxDailyTradesS
NFT Rules ****************
/****************************************
******** Token Max Daily Trades ********


```solidity
struct TokenMaxDailyTradesS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.TokenMaxDailyTrades)) tokenMaxDailyTradesRules;
    uint32 tokenMaxDailyTradesIndex;
}
```

### AccountMaxValueByRiskScoreS
Risk Rules ****************
/****************************************
******** Account Max Value By Risk Score Rules ********


```solidity
struct AccountMaxValueByRiskScoreS {
    mapping(uint32 => IApplicationRules.AccountMaxValueByRiskScore) accountMaxValueByRiskScoreRules;
    uint32 accountMaxValueByRiskScoreIndex;
}
```

### AccountMaxTxValueByRiskScoreS
******** Account Max Transaction Value By Period Rules ********


```solidity
struct AccountMaxTxValueByRiskScoreS {
    mapping(uint32 => IApplicationRules.AccountMaxTxValueByRiskScore) accountMaxTxValueByRiskScoreRules;
    uint32 accountMaxTxValueByRiskScoreIndex;
}
```

### AMMFeeRuleS
Fee Rules ****************
/****************************************
******** AMM Fee Rule ********


```solidity
struct AMMFeeRuleS {
    mapping(uint32 => IFeeRules.AMMFeeRule) ammFeeRules;
    uint32 ammFeeRuleIndex;
}
```

