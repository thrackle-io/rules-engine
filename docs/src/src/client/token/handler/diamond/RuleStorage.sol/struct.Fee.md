# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/06e770e8df9f2623305edd5cd2be197d5544e702/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

