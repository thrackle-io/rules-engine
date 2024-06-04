# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/effe36d0b962730eb7c7e200cfcfde3ca3773db8/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

