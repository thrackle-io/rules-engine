# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0add9b8cd140006448dad92dd54fc23fca23f012/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

