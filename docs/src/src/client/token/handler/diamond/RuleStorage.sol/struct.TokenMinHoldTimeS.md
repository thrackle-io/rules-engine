# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/7233064f299d77880af0e175a21e23e2f8b85f56/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

