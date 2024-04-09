# TokenMaxSupplyVolatilityS
[Git Source](https://github.com/thrackle-io/tron/blob/f0e9b435619e8bdc38f4e9105781dfc663d9f089/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxSupplyVolatilityS {
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
}
```

