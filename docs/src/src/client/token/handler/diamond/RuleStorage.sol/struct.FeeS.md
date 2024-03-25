# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/764000f27aa19925e60dae8d757a097eec620706/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

