# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/0336bb34620bb9e55e13cd371f0aebd8997d21c3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

