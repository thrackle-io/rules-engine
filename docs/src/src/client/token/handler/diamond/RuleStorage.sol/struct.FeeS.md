# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/fa1f71d854feb4f93c1bbe77dbe731527e9e3d00/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

