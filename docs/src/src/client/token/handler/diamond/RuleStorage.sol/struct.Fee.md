# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/192018a749cd70c7df311296c3236b79e11af0f3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

