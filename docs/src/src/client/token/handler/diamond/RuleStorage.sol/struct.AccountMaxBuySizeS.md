# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/6347e28a06cfe8dcc416f54eea2d35ee6b0ce9fd/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

