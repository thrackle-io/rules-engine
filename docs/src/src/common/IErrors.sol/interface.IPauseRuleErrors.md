# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/8e8136863cc533050498938ef97f694c7b6600c3/src/common/IErrors.sol)


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

