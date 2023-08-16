# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/interfaces/IErrors.sol)


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

