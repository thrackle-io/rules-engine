# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/93fd74340f7444498e4353b2c758c1107038174a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

