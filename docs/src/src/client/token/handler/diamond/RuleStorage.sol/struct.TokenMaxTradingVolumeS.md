# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/5dd4d5c11842d5927a5d94b280633ba0762dc45b/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

