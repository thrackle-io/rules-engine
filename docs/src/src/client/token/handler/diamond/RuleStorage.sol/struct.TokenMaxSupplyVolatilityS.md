# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/edf3093a9fed22d64a8edbc89ae73bfbadfe2a42/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

