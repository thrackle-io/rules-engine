# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/7030db34eb7187742ede73deed40ef4d7dddaa1b/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

