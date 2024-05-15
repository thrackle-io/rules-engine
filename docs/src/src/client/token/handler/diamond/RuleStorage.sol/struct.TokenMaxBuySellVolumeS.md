# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/1ba87bf9bb403411ce677f8e83126c3bf8cfa713/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

