# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/ce8f3ce20cc777375e5a3cbfcde63db2607acc28/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

