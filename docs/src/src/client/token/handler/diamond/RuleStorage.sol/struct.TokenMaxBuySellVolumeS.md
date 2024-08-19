# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/57b349a6cc320a1f7ecb037fec845111fdd03ebb/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

