# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/5b7fc1e99a9efe7cd4509a3bd8aa91769d651104/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

