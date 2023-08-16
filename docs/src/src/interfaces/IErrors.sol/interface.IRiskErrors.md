# IRiskErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/interfaces/IErrors.sol)


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

