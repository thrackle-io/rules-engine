# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/af28404fa455abf3b77fe8e040ff86d48b926353/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

