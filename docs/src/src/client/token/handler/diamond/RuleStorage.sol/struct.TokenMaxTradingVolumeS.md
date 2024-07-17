# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/9a96151c4e4157dea6fb1f2313711b4be2ae0f47/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

