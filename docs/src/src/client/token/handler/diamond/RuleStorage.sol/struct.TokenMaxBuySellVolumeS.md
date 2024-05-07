# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/13349942d6b36cb5b881624be044b28167a194cf/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

