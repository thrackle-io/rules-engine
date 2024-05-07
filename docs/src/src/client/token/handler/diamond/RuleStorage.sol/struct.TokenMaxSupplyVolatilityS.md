# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/845c12315ef4ac1a6cc2b1c3212b2b372da974eb/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

