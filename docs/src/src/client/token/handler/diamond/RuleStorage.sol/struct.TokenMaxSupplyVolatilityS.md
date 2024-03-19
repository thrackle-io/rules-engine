# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/f0b9409d0746d035136fce54b3907220cf162a23/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

