# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/f7f6e3590faaa9c8f0fe0115492201b8f8dd1711/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

