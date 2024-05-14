# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/56352a4526d6a87b8ae2304732a66802674fba29/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

