# Fee
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/3646d7220ca1c3c6e396c1c58012716f59073c50/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

