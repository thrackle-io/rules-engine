# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/ad4d24a5f2b61a5f8e2561806bd722c0cc64e81a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

