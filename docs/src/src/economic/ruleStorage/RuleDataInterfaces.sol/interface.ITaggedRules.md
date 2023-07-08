# ITaggedRules
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/1ab1db06d001c0ea3265ec49b85ddd9394430302/src/economic/ruleStorage/RuleDataInterfaces.sol)


## Structs
### PurchaseRule
******** Account Purchase Rules ********


```solidity
struct PurchaseRule {
    uint256 purchaseAmount;
    uint32 purchasePeriod;
    uint64 startTime;
}
```

### SellRule
******** Account Sell Rules ********


```solidity
struct SellRule {
    uint256 sellAmount;
    uint32 sellPeriod;
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

### BalanceLimitRule
******** Minimum/Maximum Account Balances ********


```solidity
struct BalanceLimitRule {
    uint256 minimum;
    uint256 maximum;
}
```

### AdminWithdrawalRule
******** Admin Withdrawal Rules ********


```solidity
struct AdminWithdrawalRule {
    uint256 amount;
    uint256 releaseDate;
}
```

### TransactionSizeToRiskRule
******** Transaction Size Rules ********


```solidity
struct TransactionSizeToRiskRule {
    uint8[] riskLevel;
    uint48[] maxSize;
}
```

### MinBalByDateRule
******** Minimum Balance By Date Rules ********


```solidity
struct MinBalByDateRule {
    uint256 holdAmount;
    uint256 holdPeriod;
    uint256 startTimeStamp;
}
```

