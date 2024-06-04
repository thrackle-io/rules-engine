# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/effe36d0b962730eb7c7e200cfcfde3ca3773db8/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

