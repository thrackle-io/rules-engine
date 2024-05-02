# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/502533a6ffb2af342c0e88aaf7562842e91b57b1/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

