# ITaggedRules
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


## Structs
### PurchaseRule
******** Account Purchase Rules ********


```solidity
struct PurchaseRule {
    uint256 maxSize;
    uint16 period;
    uint64 startTime;
}
```

### SellRule
******** Account Sell Rules ********


```solidity
struct SellRule {
    uint256 sellAmount;
    uint16 sellPeriod;
    uint64 startTime;
}
```

### WithdrawalRule
******** Account Withdrawal Rules ********


```solidity
struct WithdrawalRule {
    uint256 amount;
    uint256 releaseDate;
}
```

### MinMaxBalanceRule
******** Minimum/Maximum Account Balances ********


```solidity
struct MinMaxBalanceRule {
    uint256 minimum;
    uint256 maximum;
}
```

### AdminMinTokenBalance
******** Admin Withdrawal Rules ********


```solidity
struct AdminMinTokenBalance {
    uint256 amount;
    uint256 releaseDate;
}
```

### TransactionSizeToRiskRule
******** Transaction Size Rules ********


```solidity
struct TransactionSizeToRiskRule {
    uint8[] riskScore;
    uint48[] maxSize;
}
```

### MinBalByDateRule
******** Minimum Balance By Date Rules ********


```solidity
struct MinBalByDateRule {
    uint256 holdAmount;
    uint16 holdPeriod;
    uint256 startTimeStamp;
}
```

### TokenMaxDailyTrades
******** NFT ********


```solidity
struct TokenMaxDailyTrades {
    uint8 tradesAllowedPerDay;
    uint64 startTs;
}
```

