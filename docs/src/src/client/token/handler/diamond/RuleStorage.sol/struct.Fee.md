# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/570e509b7dae1b89ffe858956bb3df9bbac2510a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

