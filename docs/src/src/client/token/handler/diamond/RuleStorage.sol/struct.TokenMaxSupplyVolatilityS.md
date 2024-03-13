# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/263e499d66345014a4fa5059735434da59124980/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

