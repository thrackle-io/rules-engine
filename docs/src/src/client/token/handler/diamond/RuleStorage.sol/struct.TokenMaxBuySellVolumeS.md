# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/29c0f577f4a40a4ed7ae1702ee35ca11ff1ccfaf/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

