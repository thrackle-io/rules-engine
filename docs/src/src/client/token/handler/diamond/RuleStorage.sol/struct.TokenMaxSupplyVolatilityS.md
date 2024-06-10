# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/bcd51b65303028319f618c7ac3ded4f0d5f7d964/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

