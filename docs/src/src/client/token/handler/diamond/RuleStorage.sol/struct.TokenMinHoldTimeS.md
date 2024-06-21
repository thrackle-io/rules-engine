# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/873b14e2bfb8e3c0ec1e8bf0bb215076bd1e60ce/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

