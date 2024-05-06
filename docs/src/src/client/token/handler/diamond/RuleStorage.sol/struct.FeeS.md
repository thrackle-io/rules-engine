# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/570e509b7dae1b89ffe858956bb3df9bbac2510a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

