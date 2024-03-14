# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/a0e7b20980bb06404eb010a144cfad3764962831/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

