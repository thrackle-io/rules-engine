# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/977acada486f4d8e6eb8170b55a9be84cb27aa08/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

