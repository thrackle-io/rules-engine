# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/d9139140f50076b996b790d1128c5e2182de1d13/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

