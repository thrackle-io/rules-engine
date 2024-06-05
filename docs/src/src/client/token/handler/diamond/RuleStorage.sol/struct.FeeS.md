# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/f74908398c760797afd44dcdc70a8e3cb8ae80a1/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

