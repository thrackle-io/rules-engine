# Fee
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/cb826e7b7899f2d90490d1eaeb0e665e017648fa/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeSink;
}
```

