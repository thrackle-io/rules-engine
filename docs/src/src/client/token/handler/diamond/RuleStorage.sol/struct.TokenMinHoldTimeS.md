# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/5c20e54658e3206ed81b54d70494bea2d0a0e5dd/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

