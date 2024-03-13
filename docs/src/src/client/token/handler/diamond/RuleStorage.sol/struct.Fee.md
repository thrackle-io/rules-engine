# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/263e499d66345014a4fa5059735434da59124980/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

