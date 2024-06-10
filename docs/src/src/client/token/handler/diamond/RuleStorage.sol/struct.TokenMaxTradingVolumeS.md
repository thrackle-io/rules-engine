# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/bcd51b65303028319f618c7ac3ded4f0d5f7d964/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

