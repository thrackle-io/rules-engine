# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/bcbcc01a5b28a551282aabeb3b2db849eb2ab94f/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

