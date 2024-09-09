# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/1f87ef51d3f81854db8d1b233a920d59919e0ac3/src/common/IErrors.sol)


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

