# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/83f9171b0938eaf7bc30d655175a8e0d5f93feb4/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

