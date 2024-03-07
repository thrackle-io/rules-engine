# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/3cbe4e765eb8a4f99ff305a3831acec21bbc5481/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

