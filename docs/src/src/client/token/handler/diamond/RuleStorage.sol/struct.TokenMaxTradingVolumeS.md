# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/4f1430717249c90fcbde9d9572fe2ac92dc2c5d4/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

