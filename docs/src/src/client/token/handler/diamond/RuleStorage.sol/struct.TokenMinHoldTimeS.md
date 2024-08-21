# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/bcad51a5d60a6bc42c4bd815f4a14c769889cdc7/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

