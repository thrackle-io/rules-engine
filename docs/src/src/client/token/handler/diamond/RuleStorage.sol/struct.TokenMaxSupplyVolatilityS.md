# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/bb9fb29098b7e62d948f810420d516cd6ca78012/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

