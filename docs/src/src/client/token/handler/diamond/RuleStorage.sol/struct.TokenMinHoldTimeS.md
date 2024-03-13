# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/4b8e6b6f1f58764b58a041110acc182dd905d211/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

