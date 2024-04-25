# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/8f8cd9f0e8cf797290e5a764c49efd646c572381/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

