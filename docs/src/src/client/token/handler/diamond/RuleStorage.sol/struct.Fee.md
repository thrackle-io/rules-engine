# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/35220e3468902ae927d760ed6963ae4507446c20/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

