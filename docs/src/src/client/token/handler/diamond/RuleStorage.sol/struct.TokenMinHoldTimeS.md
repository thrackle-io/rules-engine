# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/effe36d0b962730eb7c7e200cfcfde3ca3773db8/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

