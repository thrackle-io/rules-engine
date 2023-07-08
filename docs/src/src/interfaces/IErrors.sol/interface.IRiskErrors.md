# IRiskErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/1ab1db06d001c0ea3265ec49b85ddd9394430302/src/interfaces/IErrors.sol)


## Errors
### MaxTxSizePerPeriodReached

```solidity
error MaxTxSizePerPeriodReached(uint8 riskScore, uint256 maxTxSize, uint8 hoursOfPeriod);
```

### TransactionExceedsRiskScoreLimit

```solidity
error TransactionExceedsRiskScoreLimit();
```

### BalanceExceedsRiskScoreLimit

```solidity
error BalanceExceedsRiskScoreLimit();
```

