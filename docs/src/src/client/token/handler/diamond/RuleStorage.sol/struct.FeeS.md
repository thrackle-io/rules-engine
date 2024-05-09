# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/38ad28ed586c360d4509e485bd378da51297351d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

