# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/38ad28ed586c360d4509e485bd378da51297351d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

