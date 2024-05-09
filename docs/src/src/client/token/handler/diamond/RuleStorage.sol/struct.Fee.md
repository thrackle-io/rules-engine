# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/90f80c15b8a320b76e44e84890aab8b010252d59/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

