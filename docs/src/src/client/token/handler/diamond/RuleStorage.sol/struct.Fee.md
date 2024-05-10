# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/9006c7893599df6faee125cfb638dc80c156ce12/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

