# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/cc518f3968132c6914cbdf581f9e9c0cee9a912e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

