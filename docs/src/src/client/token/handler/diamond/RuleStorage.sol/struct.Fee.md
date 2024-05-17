# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/93fd74340f7444498e4353b2c758c1107038174a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

