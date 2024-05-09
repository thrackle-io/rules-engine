# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/362ca5d8826deeb3c732b79b0826e739dff4e241/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

