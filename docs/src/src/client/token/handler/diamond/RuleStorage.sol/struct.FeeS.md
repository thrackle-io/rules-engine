# FeeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/459b520a7107e726ba8e04fbad518d00575c4ce1/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

