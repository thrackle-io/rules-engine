# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/3811b4273256819e871165284a320ac92fbb3641/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

