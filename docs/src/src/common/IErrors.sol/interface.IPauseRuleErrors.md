# IPauseRuleErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0775549ba2fe667ec66be14a19fcc8b784774a43/src/common/IErrors.sol)


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

