# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/362ca5d8826deeb3c732b79b0826e739dff4e241/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

