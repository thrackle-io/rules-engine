# Fee
[Git Source](https://github.com/thrackle-io/rules-engine/blob/6d65728d4e93813016499a87fe04f8385b777100/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

