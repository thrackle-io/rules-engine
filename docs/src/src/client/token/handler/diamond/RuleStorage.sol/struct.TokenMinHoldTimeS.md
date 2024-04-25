# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/bbc344dde218df220c4305ef421070eaa38c5cad/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

