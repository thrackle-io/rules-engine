# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/4674814db01d3b90ed90d394187432e47d662f5c/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

