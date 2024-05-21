# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/eb8a3e1cf83581100fd90ef911919e537c2c55cb/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

