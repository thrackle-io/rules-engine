# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/8f688cb5e6148d0b374ef77b936d7812ad0892e1/src/common/IErrors.sol)


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

