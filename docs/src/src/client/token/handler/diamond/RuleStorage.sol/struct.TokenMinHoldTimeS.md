# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/9f8d8e88474215a5428a3c0196051d47d58e8650/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

