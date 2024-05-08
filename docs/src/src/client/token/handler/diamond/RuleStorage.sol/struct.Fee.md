# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/0336bb34620bb9e55e13cd371f0aebd8997d21c3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

