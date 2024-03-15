# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/7030db34eb7187742ede73deed40ef4d7dddaa1b/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

