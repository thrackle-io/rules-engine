# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/67919752074a6ad99319926c762bce79963a8aa4/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

