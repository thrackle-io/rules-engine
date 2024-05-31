# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/703713c2070ab34d0f0fc0114244d5a3fa7ac84a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

