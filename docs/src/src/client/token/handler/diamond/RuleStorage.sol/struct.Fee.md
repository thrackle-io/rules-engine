# Fee
[Git Source](https://github.com/thrackle-io/rules-engine/blob/ce3e124fbb7b1c9745b955077cf9cd260c5eabe5/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

