# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/4b8e6b6f1f58764b58a041110acc182dd905d211/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

