# TokenMaxTradingVolumeS
[Git Source](https://github.com/thrackle-io/tron/blob/12b8f8795779c791ed3113763e21492860614b51/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct TokenMaxTradingVolumeS {
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
}
```

