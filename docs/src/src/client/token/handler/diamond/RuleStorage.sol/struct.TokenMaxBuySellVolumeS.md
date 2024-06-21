# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/e8b36a3b12094b00c1b143dd36d9acbc1f486a67/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

