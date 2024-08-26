# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/3234c3c6e5bf5f01811a34cd7cc6e00de73aa6c7/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

