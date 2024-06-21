# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/e8b36a3b12094b00c1b143dd36d9acbc1f486a67/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

