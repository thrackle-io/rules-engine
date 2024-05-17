# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/f3bd6a25d2a231a2f0551b95491d3fdfe01415dc/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

