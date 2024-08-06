# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/35ec513a185f22e7ba035815b9ced8c0ef1497a9/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

