# AccountMaxTradeSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/a32755ef70ede3dfc3a49e226e4b15ac07a36ebd/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxTradeSizeS {
    mapping(ActionTypes => Rule) accountMaxTradeSize;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

