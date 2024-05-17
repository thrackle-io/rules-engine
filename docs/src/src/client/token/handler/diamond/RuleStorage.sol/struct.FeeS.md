# FeeS
[Git Source](https://github.com/thrackle-io/tron/blob/93fd74340f7444498e4353b2c758c1107038174a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct FeeS {
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
```

