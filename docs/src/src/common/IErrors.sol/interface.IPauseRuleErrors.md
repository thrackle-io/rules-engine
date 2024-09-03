# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/ea7b4b1d8c8b9c92a6391cd0b67fbb323cf4419d/src/common/IErrors.sol)


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

