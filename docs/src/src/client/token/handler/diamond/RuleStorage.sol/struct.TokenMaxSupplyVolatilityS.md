# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/418593f8a1f14afa022635321794b26239d6f80e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

