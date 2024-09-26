# Fee
[Git Source](https://github.com/thrackle-io/rules-engine/blob/9f8d8e88474215a5428a3c0196051d47d58e8650/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

