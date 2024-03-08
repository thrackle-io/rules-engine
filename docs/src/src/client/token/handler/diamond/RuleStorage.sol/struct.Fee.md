# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

