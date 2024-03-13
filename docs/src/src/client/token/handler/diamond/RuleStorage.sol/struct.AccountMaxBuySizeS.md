# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/263e499d66345014a4fa5059735434da59124980/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

