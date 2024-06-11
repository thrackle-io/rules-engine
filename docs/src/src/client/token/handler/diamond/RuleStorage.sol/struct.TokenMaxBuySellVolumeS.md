# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/50727ee9211084f05b8690e3435981873338f44e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

