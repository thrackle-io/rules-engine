# IRuleStorage
[Git Source](https://github.com/thrackle-io/rules-engine/blob/3234c3c6e5bf5f01811a34cd7cc6e00de73aa6c7/src/protocol/economic/ruleProcessor/IRuleStorage.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This interface outlines the storage structures for each rule stored in diamond

*The data structure of each rule storage inside the diamond.*


## Structs
### AccountMaxTradeSizeS
Note The following are market-related oppertation rules. Checks depend on the
accuracy of the method to determine when a transfer is part of a trade and what
direction it is taking (buy or sell).
******** Account Max Trade Sizes ********


```solidity
struct AccountMaxTradeSizeS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.AccountMaxTradeSize)) accountMaxTradeSizeRules;
    mapping(uint32 => uint64) startTimes;
    uint32 accountMaxTradeSizeIndex;
}
```

### TokenMaxBuySellVolumeS
******** Token Max Buy Sell Volume ********


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(uint32 => INonTaggedRules.TokenMaxBuySellVolume) tokenMaxBuySellVolumeRules;
    uint32 tokenMaxBuySellVolumeIndex;
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

### TokenMinHoldTimeS
******** Token Min Hold Time ********


```solidity
struct TokenMinHoldTimeS {
    mapping(uint32 => INonTaggedRules.TokenMinHoldTime) tokenMinHoldTimeRules;
    uint32 tokenMinHoldTimeIndex;
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

### EnabledActions
******** Storage of RuleApplicationValidationFacet ********


```solidity
struct EnabledActions {
    mapping(bytes32 => mapping(ActionTypes => bool)) isActionEnabled;
}
```

