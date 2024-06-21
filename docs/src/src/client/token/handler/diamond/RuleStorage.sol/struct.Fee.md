# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/873b14e2bfb8e3c0ec1e8bf0bb215076bd1e60ce/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

