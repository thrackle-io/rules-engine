# IRiskErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/d0344b27291308c442daefb74b46bb81740099e4/src/interfaces/IErrors.sol)


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

