# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/cc518f3968132c6914cbdf581f9e9c0cee9a912e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

