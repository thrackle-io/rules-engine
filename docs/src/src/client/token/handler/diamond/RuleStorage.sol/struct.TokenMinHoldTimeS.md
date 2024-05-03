# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/cc8b8345c329b2556fa21578401d762291784e46/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

