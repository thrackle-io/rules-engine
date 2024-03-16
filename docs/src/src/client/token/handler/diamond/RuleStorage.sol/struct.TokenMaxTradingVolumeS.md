# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/d5c4da9c910c7f583b74a714399bd64fbb32b616/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

