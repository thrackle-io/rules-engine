# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/17f0c18311739ad27e810cec2eb3f45ea28c2fd7/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

