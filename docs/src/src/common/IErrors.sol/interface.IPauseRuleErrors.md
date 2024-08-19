# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/57b349a6cc320a1f7ecb037fec845111fdd03ebb/src/common/IErrors.sol)


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

