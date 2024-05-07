# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/845c12315ef4ac1a6cc2b1c3212b2b372da974eb/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

