# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/3234c3c6e5bf5f01811a34cd7cc6e00de73aa6c7/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

