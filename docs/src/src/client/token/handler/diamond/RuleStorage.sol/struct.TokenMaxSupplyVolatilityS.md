# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/5f7e8f952b779123753dfeb3491892f00fd8b936/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

