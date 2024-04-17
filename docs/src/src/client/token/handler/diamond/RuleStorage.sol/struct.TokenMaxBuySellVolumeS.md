# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/2c06fb72526db5cd6662cbeec5fef5842b764c6f/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

