# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/5b4c46cba4728d833e07b42f737a689087f379aa/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

