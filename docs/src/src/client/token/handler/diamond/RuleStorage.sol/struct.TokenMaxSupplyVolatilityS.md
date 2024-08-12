# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/47aa0c8585077f5b931483a9b3097e3fe330a3c3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

