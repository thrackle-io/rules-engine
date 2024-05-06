# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/5f7e8f952b779123753dfeb3491892f00fd8b936/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

