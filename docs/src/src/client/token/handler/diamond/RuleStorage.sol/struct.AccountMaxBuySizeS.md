# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/17f0c18311739ad27e810cec2eb3f45ea28c2fd7/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

