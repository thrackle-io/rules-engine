# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/f405cfa7d52aca0d1bdf3d82da9748579a0bb635/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

