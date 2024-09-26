# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/9f8d8e88474215a5428a3c0196051d47d58e8650/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

