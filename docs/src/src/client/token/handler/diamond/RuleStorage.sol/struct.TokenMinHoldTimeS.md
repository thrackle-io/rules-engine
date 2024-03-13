# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/1a1d6b2809bc510780a53bad6853fa1ef1652aab/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

