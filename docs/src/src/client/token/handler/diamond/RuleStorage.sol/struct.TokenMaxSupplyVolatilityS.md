# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/0c70bcd32f4dcc456508b64e73411cac76dd6f09/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

