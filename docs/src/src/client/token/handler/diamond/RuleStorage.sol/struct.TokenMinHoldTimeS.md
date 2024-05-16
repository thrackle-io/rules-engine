# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/a6e068f4bc8dd6e86015430d874759ac1519196d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

