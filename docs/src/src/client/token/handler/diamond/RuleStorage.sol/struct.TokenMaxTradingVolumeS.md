# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/d12cfa3cb48422acc5d155aaf1a5d1ffab60585d/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

