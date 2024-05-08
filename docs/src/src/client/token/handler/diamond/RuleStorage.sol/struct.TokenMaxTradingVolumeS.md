# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/0336bb34620bb9e55e13cd371f0aebd8997d21c3/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

