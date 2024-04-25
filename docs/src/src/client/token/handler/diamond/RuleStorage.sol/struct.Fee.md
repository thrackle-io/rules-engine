# Fee
[Git Source](https://github.com/thrackle-io/tron/blob/81b80009ad5682c206d626e3be15fff689d615e0/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}
```

