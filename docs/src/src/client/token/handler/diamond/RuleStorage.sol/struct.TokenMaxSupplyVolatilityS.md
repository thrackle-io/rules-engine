# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/67919752074a6ad99319926c762bce79963a8aa4/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

