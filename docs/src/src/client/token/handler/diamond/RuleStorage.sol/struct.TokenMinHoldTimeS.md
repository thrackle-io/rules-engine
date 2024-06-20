# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/162302962dc6acd8eb4a5fadda6be1dbd5a16028/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
    uint256 ruleChangeDate;
    bool anyActionActive;
}
```

