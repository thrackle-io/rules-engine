# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/9e3814d522f1469f798bac69a12de09ee849e2da/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

