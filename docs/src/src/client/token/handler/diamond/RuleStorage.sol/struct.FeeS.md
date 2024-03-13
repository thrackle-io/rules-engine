# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/5bfb84a51be01d9a959b76979e9b34e41875da67/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

