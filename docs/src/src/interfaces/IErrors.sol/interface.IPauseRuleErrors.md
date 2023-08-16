# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/d0344b27291308c442daefb74b46bb81740099e4/src/interfaces/IErrors.sol)


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

