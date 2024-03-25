# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/764000f27aa19925e60dae8d757a097eec620706/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

