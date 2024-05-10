# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/bb9fb29098b7e62d948f810420d516cd6ca78012/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

