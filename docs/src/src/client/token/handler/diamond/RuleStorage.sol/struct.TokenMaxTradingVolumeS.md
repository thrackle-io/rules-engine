# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/1e4e061752cea9c86408a9ccfc7ebc0d0de4bb9a/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

