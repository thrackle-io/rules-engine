# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/362ca5d8826deeb3c732b79b0826e739dff4e241/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

