# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/3cbe4e765eb8a4f99ff305a3831acec21bbc5481/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

