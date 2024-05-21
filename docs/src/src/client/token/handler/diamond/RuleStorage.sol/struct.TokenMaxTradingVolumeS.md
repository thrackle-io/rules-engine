# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/3811b4273256819e871165284a320ac92fbb3641/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

