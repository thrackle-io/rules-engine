# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/8f688cb5e6148d0b374ef77b936d7812ad0892e1/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

