# AccountMaxTradeSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/50727ee9211084f05b8690e3435981873338f44e/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxTradeSizeS {
    mapping(ActionTypes => Rule) accountMaxTradeSize;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
    uint256 ruleChangeDate;
}
```

