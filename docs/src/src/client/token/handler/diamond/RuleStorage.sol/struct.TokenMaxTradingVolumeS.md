# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/e7a29d289e813f2ec0afb244343b31481470bf5f/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

