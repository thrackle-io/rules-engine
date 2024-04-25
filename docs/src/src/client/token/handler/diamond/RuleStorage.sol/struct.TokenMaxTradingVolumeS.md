# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/bbc344dde218df220c4305ef421070eaa38c5cad/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

