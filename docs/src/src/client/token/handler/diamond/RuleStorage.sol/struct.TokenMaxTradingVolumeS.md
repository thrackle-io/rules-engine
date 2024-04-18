# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/4370cba4c6c86564c45ea5da17298f68b13753b5/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

