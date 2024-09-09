# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/1f87ef51d3f81854db8d1b233a920d59919e0ac3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

