# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/826eee0e9167e4ceebe5bb3df2058b377df8b6bc/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

