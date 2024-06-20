# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/162302962dc6acd8eb4a5fadda6be1dbd5a16028/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

