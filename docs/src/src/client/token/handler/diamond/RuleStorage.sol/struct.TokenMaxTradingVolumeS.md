# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/90c179d4a2d3d05eb80cb7a50ea4891339d7488e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

