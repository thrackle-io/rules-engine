# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/ca86a0ac3b5737f1c6c7b1df4820e4363feb10cd/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

