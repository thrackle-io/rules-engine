# AccountMaxSellSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/a0f5ead5c8fc9d4614336dc446184e42c1f4b0fa/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxSellSizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

