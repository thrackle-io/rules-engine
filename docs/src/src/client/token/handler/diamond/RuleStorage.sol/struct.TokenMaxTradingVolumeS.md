# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0add9b8cd140006448dad92dd54fc23fca23f012/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

