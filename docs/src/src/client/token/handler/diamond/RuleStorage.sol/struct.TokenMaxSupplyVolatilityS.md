# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/a32755ef70ede3dfc3a49e226e4b15ac07a36ebd/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

