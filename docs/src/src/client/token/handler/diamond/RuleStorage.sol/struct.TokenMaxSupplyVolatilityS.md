# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/4e6a814efa6ccf934f63826b54087808a311218d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

