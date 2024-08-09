# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/00cdc21330585fccf9dc326a2f7aeba02706eb37/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

