# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/16aa388bf7edf8163f2f93600ba5d420a17a40c0/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

