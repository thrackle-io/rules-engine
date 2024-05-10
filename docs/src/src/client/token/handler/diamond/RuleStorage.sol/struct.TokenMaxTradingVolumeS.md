# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/9006c7893599df6faee125cfb638dc80c156ce12/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

