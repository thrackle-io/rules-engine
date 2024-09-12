# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/459b520a7107e726ba8e04fbad518d00575c4ce1/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

