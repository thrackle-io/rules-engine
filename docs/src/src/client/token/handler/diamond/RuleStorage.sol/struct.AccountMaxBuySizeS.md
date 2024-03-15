# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/f201d50818b608b30301a670e76c0b866af89050/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

