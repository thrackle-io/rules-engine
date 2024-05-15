# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/1ba87bf9bb403411ce677f8e83126c3bf8cfa713/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

