# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/13349942d6b36cb5b881624be044b28167a194cf/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

