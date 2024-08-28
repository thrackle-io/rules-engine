# INonTaggedRules
[Git Source](https://github.com/thrackle-io/rules-engine/blob/5dd4d5c11842d5927a5d94b280633ba0762dc45b/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*data structures of each rule in the protocol, grouped by rule subset
(NonTagged Rules, Tagged rules, AccessLevel rules, Risk rules, and Fee rules)*


## Structs
### TokenMinTxSize
******** Token Min Tx Size Rules ********


```solidity
struct TokenMinTxSize {
    uint256 minSize;
}
```

### TokenMaxBuySellVolume
******** Token Max Buy Sell Volume Rules ********


```solidity
struct TokenMaxBuySellVolume {
    uint16 tokenPercentage;
    uint16 period;
    uint256 totalSupply;
    uint64 startTime;
}
```

### TokenPurchaseFeeByVolume
******** Token Purchase Fee By Volume Rules ********


```solidity
struct TokenPurchaseFeeByVolume {
    uint256 volume;
    uint16 rateIncreased;
}
```

### TokenMaxPriceVolatility
******** Token Max Price Volatility ********


```solidity
struct TokenMaxPriceVolatility {
    uint16 max;
    uint16 period;
    uint16 hoursFrozen;
    uint256 totalSupply;
}
```

### TokenMaxTradingVolume
******** Token Max Trading Volume ********


```solidity
struct TokenMaxTradingVolume {
    uint24 max;
    uint16 period;
    uint64 startTime;
    uint256 totalSupply;
}
```

### TokenMaxSupplyVolatility
******** Supply Volatility ********


```solidity
struct TokenMaxSupplyVolatility {
    uint16 max;
    uint16 period;
    uint64 startTime;
    uint256 totalSupply;
}
```

### AccountApproveDenyOracle
******** Account Approve/Deny Oracle ********


```solidity
struct AccountApproveDenyOracle {
    uint8 oracleType;
    address oracleAddress;
}
```

### TokenMinHoldTime
******** Token Min Hold Time ********


```solidity
struct TokenMinHoldTime {
    uint32 minHoldTime;
}
```

