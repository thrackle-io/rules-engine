# TokenMaxBuySellVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/63fcd46f6c4c395f84afa43dab91856da44b1c42/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxBuySellVolumeS {
    mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
    uint256 salesInPeriod;
    uint64 lastSellTime;
}
```

