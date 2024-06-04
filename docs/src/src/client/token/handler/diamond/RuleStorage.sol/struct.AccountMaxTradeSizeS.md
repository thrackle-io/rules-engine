# AccountMaxTradeSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/effe36d0b962730eb7c7e200cfcfde3ca3773db8/src/client/token/handler/diamond/RuleStorage.sol)


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

