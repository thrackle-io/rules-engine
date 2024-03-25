# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/764000f27aa19925e60dae8d757a097eec620706/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

