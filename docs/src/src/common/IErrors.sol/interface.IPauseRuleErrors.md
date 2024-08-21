# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/bcad51a5d60a6bc42c4bd815f4a14c769889cdc7/src/common/IErrors.sol)


## Errors
### ApplicationPaused

```solidity
error ApplicationPaused(uint256 started, uint256 ends);
```

### InvalidDateWindow

```solidity
error InvalidDateWindow(uint256 startDate, uint256 endDate);
```

### MaxPauseRulesReached

```solidity
error MaxPauseRulesReached();
```

