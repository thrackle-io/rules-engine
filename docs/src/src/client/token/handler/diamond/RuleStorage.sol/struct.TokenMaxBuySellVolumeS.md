# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/845c12315ef4ac1a6cc2b1c3212b2b372da974eb/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

