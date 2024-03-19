# AccountMaxSellSizeS
[Git Source](https://github.com/thrackle-io/tron/blob/f0b9409d0746d035136fce54b3907220cf162a23/src/client/token/handler/diamond/RuleStorage.sol)


```solidity
struct AccountMaxSellSizeS {
    uint32 id;
    bool active;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
}
```

