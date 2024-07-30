# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/0c22edbee3ca4c32dcba8042eeb10bc1a6c3bdd0/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

