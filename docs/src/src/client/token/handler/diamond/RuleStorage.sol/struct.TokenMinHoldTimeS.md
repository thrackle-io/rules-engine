# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/16aa388bf7edf8163f2f93600ba5d420a17a40c0/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

