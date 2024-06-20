# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/162302962dc6acd8eb4a5fadda6be1dbd5a16028/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

