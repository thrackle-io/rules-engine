# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/502533a6ffb2af342c0e88aaf7562842e91b57b1/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

