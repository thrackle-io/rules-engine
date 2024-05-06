# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/4e6a814efa6ccf934f63826b54087808a311218d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

