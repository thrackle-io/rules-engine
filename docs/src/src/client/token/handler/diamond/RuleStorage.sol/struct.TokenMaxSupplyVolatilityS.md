# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/268b521956cf89a918ed12522e8182d2df0cd3b2/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

