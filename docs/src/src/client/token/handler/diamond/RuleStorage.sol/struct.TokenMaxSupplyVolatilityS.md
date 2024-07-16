# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/39d269094241d21cf978e159a9b52cf3c140671a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

