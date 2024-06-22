# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/d5d71b820b889f2fefe2639a8f5979e5f09110ed/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

