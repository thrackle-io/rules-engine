# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/0ca0a263215b0baace3d8d12fd9706eb2a79accf/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

