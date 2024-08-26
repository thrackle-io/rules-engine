# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/3234c3c6e5bf5f01811a34cd7cc6e00de73aa6c7/src/common/IErrors.sol)


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

