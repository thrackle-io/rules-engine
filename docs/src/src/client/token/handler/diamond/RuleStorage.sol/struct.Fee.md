# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/703713c2070ab34d0f0fc0114244d5a3fa7ac84a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

