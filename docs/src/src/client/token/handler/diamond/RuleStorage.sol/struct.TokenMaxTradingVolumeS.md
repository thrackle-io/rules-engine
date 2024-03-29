# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/d3ca0c014d883c12f0128d8139415e7b12c9e982/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

