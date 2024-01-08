# ITaggedRules
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


## Structs
### PurchaseRule
******** Account Purchase Rules ********


```solidity
struct PurchaseRule {
    uint256 purchaseAmount;
    uint16 purchasePeriod;
}
```

### SellRule
******** Account Sell Rules ********


```solidity
struct SellRule {
    uint256 sellAmount;
    uint16 sellPeriod;
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
    uint16 holdPeriod;
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

