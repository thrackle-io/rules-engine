# RULE
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/a2d57139b7236b5b0e9a0727e55f81e5332cd216/src/economic/ruleStorage/RuleCodeData.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

VERSION 1

Rule enum houses enumerative list of rules for immutability

*This enum is a representation of the positioning inside the
rule_set array of the protocol.*


```solidity
enum RULE {
    PURCHASE,
    SELL,
    PCT_PURCHASE,
    PCT_SELL,
    PURCHASE_FEE_PER_VOL,
    VOLATILITY,
    TRADING_VOL,
    WIDTHDRAWAL,
    ADMIN_WIDTHDRAWAL,
    MIN_TRANSFER,
    BALANCE_LIMIT,
    MIN_BALANCE_HELD_BY_PERIOD,
    SUPPLY_VOLATILITY,
    AccessLevel,
    TX_SIZE_TO_RISK,
    TX_SIZE_PER_PERIOD_TO_RISK,
    ACCOUNT_BALANCE,
    ORACLE,
    WITHDRAWAL_LIMIT_ACCESS_LEVEL
}
```

