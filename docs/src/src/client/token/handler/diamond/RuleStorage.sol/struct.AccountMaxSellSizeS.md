# AccountMaxSellSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/bcbcc01a5b28a551282aabeb3b2db849eb2ab94f/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxSellSizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

