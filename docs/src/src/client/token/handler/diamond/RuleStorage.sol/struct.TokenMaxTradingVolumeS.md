# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/bb9fb29098b7e62d948f810420d516cd6ca78012/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

