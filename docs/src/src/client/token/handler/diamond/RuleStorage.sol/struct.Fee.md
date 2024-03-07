# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/d6cc09e8b231cc94d92dd93b6d49fb2728ede233/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

