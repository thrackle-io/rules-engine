# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/ce3e124fbb7b1c9745b955077cf9cd260c5eabe5/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

