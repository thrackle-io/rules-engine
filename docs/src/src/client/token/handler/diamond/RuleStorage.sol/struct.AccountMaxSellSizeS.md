# AccountMaxSellSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/7030db34eb7187742ede73deed40ef4d7dddaa1b/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxSellSizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

