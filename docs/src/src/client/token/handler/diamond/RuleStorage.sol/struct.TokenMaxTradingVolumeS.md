# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/845c12315ef4ac1a6cc2b1c3212b2b372da974eb/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

