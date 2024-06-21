# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/1e4e061752cea9c86408a9ccfc7ebc0d0de4bb9a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

