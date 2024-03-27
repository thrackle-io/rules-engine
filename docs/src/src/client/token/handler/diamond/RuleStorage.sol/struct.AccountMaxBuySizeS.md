# AccountMaxBuySizeS
[Git Source](https://github.com/thrackle-io/tron/blob/12b8f8795779c791ed3113763e21492860614b51/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxBuySizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
}
```

