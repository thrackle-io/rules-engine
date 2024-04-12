# TokenMinHoldTimeS
[Git Source](https://github.com/thrackle-io/tron/blob/cc518f3968132c6914cbdf581f9e9c0cee9a912e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
}
```

