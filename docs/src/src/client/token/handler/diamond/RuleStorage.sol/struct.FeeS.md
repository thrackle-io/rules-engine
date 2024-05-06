# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/29c0f577f4a40a4ed7ae1702ee35ca11ff1ccfaf/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

