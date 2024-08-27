# FeeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0775549ba2fe667ec66be14a19fcc8b784774a43/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

