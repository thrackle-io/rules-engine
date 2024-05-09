# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/e7a29d289e813f2ec0afb244343b31481470bf5f/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

