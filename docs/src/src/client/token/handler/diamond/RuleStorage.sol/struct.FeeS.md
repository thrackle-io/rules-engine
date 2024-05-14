# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/56352a4526d6a87b8ae2304732a66802674fba29/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

