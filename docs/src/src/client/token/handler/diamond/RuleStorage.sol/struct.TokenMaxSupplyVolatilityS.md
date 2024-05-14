# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/aa84a9fbaba8b03f46b7a3b0774885dc91a06fa5/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

