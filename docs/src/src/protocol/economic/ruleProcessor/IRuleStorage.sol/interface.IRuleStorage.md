# IRuleStorage
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/IRuleStorage.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This interface outlines the storage structures for each rule stored in diamond

*The data structure of each rule storage inside the diamond.*


## Structs
### PurchaseRuleS
Note The following are market-related rules. Checks must be
made in AMMs rather than at token level.


```solidity
struct PurchaseRuleS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.PurchaseRule)) purchaseRulesPerUser;
    uint32 accountMaxBuySizeIndex;
}
```

### SellRuleS
******** Account Sell Rules ********


```solidity
struct SellRuleS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.SellRule)) sellRulesPerUser;
    uint32 sellRulesIndex;
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
    mapping(uint32 => INonTaggedRules.TokenPercentageSellRule) tokenMaxSellVolumeRules;
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
******** Token Volatility ********


```solidity
struct TokenMaxPriceVolatilityS {
    mapping(uint32 => INonTaggedRules.TokenMaxPriceVolatility) tokenMaxPriceVolatilityRules;
    uint32 tokenMaxPriceVolatilityIndex;
}
```

### TransferVolRuleS
******** Token Transfer Volume ********


```solidity
struct TransferVolRuleS {
    mapping(uint32 => INonTaggedRules.TokenMaxTradingVolume) tokenMaxTradingVolumeRules;
    uint32 tokenMaxTradingVolumeIndex;
}
```

### WithdrawalRuleS
******** Withdrawal Rules ********


```solidity
struct WithdrawalRuleS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.WithdrawalRule)) withdrawalRulesPerToken;
    uint32 withdrawalRulesIndex;
}
```

### AdminMinTokenBalanceS
******** Admin Withdrawal Rules ********


```solidity
struct AdminMinTokenBalanceS {
    mapping(uint32 => ITaggedRules.AdminMinTokenBalance) adminMinTokenBalanceRules;
    uint32 adminMinTokenBalanceIndex;
}
```

### TokenMinTransactionSizeS
******** Minimum Transaction ********


```solidity
struct TokenMinTransactionSizeS {
    mapping(uint32 => INonTaggedRules.TokenMinimumTransferRule) tokenMinTxSizeRules;
    uint32 tokenMinTxSizeIndex;
}
```

### MinMaxBalanceRuleS
******** Minimum/Maximum Account Balances ********


```solidity
struct MinMaxBalanceRuleS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.MinMaxBalanceRule)) accountMinMaxTokenBalanceRules;
    uint32 accountMinMaxTokenBalanceIndex;
}
```

### MinBalByDateRuleS
******** Minimum Balance By Date ********


```solidity
struct MinBalByDateRuleS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.MinBalByDateRule)) minBalByDateRulesPerUser;
    uint32 minBalByDateRulesIndex;
}
```

### TokenMaxSupplyVolatilityS
******** Supply Volatility ********


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(uint32 => INonTaggedRules.SupplyVolatilityRule) tokenMaxSupplyVolatilityRules;
    uint32 tokenMaxSupplyVolatilityIndex;
}
```

### AccountApproveDenyOracleS
******** Oracle ********


```solidity
struct AccountApproveDenyOracleS {
    mapping(uint32 => INonTaggedRules.AccountApproveDenyOracle) oracleRules;
    uint32 accountApproveDenyOracleIndex;
}
```

### MaxValueByAccessLevelS
AccessLevel Rules ***********
/****************************************
Balance Limit by Access Level


```solidity
struct MaxValueByAccessLevelS {
    mapping(uint32 => mapping(uint8 => uint48)) maxValueByAccessLevelRules;
    uint32 accountMaxValueByAccessLevelIndex;
}
```

### AccountMaxValueOutByAccessLevelS
Account Max Value Out by Access Level


```solidity
struct AccountMaxValueOutByAccessLevelS {
    mapping(uint32 => mapping(uint8 => uint48)) accountMaxValueOutByAccessLevelRules;
    uint32 accountMaxValueOutByAccessLevelIndex;
}
```

### TokenMaxDailyTradesS
NFT Rules ****************
/****************************************


```solidity
struct TokenMaxDailyTradesS {
    mapping(uint32 => mapping(bytes32 => ITaggedRules.TokenMaxDailyTrades)) tokenMaxDailyTradesRules;
    uint32 tokenMaxDailyTradesIndex;
}
```

### TxSizeToRiskRuleS
Risk Rules ****************
/****************************************
******** Transaction Size Rules ********


```solidity
struct TxSizeToRiskRuleS {
    mapping(uint32 => ITaggedRules.TransactionSizeToRiskRule) txSizeToRiskRule;
    uint32 txSizeToRiskRuleIndex;
}
```

### AccountMaxValueByRiskScoreS
******** Account Balance Rules ********


```solidity
struct AccountMaxValueByRiskScoreS {
    mapping(uint32 => IApplicationRules.AccountMaxValueByRiskScore) accountMaxValueByRiskScoreRules;
    uint32 accountMaxValueByRiskScoreIndex;
}
```

### AccountMaxTransactionValueByRiskScoreS
******** Transaction Size Per Period Rules ********


```solidity
struct AccountMaxTransactionValueByRiskScoreS {
    mapping(uint32 => IApplicationRules.AccountMaxTransactionValueByRiskScore) accountMaxTxValueByRiskScoreRules;
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

