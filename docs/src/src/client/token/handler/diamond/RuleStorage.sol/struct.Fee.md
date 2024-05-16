# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/a6e068f4bc8dd6e86015430d874759ac1519196d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

