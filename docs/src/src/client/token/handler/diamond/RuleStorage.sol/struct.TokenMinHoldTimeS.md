# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/90f80c15b8a320b76e44e84890aab8b010252d59/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

