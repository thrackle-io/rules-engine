# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/17f0c18311739ad27e810cec2eb3f45ea28c2fd7/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

