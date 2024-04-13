# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/9665732f3266b703cc028112f97a9a18c551bb91/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

