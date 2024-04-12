# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/54f7f9441857e3c2c8f186b9d669a05f288b8209/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

