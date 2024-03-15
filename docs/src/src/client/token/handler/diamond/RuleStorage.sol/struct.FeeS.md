# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/d4dc3a1319e6df3195618c1297a6c755d61cf319/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

