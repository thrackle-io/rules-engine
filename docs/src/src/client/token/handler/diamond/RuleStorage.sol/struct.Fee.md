# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/fd00dd3f701afe5991226ded04be9da490ad380d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

