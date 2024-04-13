# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/3af53b224777c5c1f4e2e734b7757bd798236667/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

