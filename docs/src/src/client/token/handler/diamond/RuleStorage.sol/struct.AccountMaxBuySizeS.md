# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

