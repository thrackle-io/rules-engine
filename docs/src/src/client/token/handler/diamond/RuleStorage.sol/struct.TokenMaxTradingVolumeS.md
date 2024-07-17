# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/29c2cd95da29b0356348370e1ddb4d7bdc24a711/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => bool) tokenMaxTradingVolume;
    uint32 ruleId;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

