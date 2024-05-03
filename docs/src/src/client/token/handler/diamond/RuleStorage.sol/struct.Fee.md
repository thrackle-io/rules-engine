# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/63fcd46f6c4c395f84afa43dab91856da44b1c42/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

