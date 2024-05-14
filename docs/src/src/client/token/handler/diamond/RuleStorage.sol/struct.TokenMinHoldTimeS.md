# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/56352a4526d6a87b8ae2304732a66802674fba29/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

