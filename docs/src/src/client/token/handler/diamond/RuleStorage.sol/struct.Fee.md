# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/4e6a814efa6ccf934f63826b54087808a311218d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

