# Fee
[Git Source](https://github.com/thrackle-io/rules-engine/blob/3a9da30daa774fa67b31c000e53f0c753deac1be/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

