# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/e7ccb5e31cec6bae24fd2e457f70702e05f2d4b6/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

