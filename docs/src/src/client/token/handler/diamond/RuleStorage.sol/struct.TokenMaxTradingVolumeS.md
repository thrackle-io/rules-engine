# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/924e2b2b2b0ddb0088202a57363e91b424c36686/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

