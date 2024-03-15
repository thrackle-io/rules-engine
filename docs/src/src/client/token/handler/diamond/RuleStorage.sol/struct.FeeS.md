# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/f201d50818b608b30301a670e76c0b866af89050/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

