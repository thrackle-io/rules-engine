# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/02db7a0f302d98149458dfe5cd5a62ffb6f478a7/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

