# Fee
[Git Source](https://github.com/thrackle-io/rules-engine/blob/977acada486f4d8e6eb8170b55a9be84cb27aa08/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

