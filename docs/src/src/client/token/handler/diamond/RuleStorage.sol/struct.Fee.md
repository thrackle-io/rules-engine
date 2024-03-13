# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/cdd8e2f67a86060a2d8df603fb8469f17f75b3ca/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

