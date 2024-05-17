# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/f3bd6a25d2a231a2f0551b95491d3fdfe01415dc/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

