# IRiskErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/32fc908f43bfbb804e52e049074d30ce661a637a/src/interfaces/IErrors.sol)


## Errors
### MaxTxSizePerPeriodReached

```solidity
error MaxTxSizePerPeriodReached(uint8 riskScore, uint256 maxTxSize, uint16 hoursOfPeriod);
```

### TransactionExceedsRiskScoreLimit

```solidity
error TransactionExceedsRiskScoreLimit();
```

### BalanceExceedsRiskScoreLimit

```solidity
error BalanceExceedsRiskScoreLimit();
```

