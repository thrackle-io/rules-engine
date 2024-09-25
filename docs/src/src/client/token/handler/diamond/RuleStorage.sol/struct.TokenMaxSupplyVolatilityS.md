# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/977acada486f4d8e6eb8170b55a9be84cb27aa08/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

