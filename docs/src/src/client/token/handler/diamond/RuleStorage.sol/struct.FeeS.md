# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/50727ee9211084f05b8690e3435981873338f44e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

