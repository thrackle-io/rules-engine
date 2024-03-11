# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/13105ed31bc78c8d50cdf97173deb83a68e88dee/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

