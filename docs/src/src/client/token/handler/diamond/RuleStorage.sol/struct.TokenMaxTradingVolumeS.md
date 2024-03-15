# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/f201d50818b608b30301a670e76c0b866af89050/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

