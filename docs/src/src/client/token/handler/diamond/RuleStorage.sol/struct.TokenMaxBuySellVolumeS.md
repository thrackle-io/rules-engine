# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/47aa0c8585077f5b931483a9b3097e3fe330a3c3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

