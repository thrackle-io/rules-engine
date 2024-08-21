# FeeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/bcad51a5d60a6bc42c4bd815f4a14c769889cdc7/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

