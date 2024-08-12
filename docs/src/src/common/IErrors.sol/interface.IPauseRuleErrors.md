# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/47aa0c8585077f5b931483a9b3097e3fe330a3c3/src/common/IErrors.sol)


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

