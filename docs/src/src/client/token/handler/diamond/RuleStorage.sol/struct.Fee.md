# Fee
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/e484b68f1ca0d10ffe5b3b006faff195ef61dcb9/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

