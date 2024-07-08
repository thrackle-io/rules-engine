# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/0ca0a263215b0baace3d8d12fd9706eb2a79accf/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
    uint32 ruleId;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

