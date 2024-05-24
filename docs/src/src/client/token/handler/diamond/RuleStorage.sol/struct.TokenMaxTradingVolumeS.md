# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/8134a3beedf036c43fc49cdc1818732eb057f270/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

