# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/f74908398c760797afd44dcdc70a8e3cb8ae80a1/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

