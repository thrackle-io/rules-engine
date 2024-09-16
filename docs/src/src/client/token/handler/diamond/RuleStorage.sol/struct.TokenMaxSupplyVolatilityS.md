# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/54db83a2c72adaf3bc2196e69cb3cf728347d98b/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

