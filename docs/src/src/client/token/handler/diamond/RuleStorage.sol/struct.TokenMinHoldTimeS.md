# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/759037970009f24ec0ac5995bf26019f0b6997be/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

