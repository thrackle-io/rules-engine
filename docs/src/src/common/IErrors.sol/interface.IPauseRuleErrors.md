# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/f3f89426d30f93406f5ff447f7284dbf958844b4/src/common/IErrors.sol)


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

