# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/977acada486f4d8e6eb8170b55a9be84cb27aa08/src/common/IErrors.sol)


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

