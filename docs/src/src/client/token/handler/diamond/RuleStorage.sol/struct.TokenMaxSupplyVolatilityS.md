# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/e7a29d289e813f2ec0afb244343b31481470bf5f/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

