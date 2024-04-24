# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/826eee0e9167e4ceebe5bb3df2058b377df8b6bc/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

