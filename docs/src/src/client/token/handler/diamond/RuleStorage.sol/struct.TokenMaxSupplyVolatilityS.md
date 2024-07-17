# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/29c2cd95da29b0356348370e1ddb4d7bdc24a711/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

