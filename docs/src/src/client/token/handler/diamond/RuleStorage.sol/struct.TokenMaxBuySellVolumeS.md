# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/418593f8a1f14afa022635321794b26239d6f80e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

