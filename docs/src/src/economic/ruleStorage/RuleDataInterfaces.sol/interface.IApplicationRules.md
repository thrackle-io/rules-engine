# IApplicationRules
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/economic/ruleStorage/RuleDataInterfaces.sol)


## Structs
### TxSizePerPeriodToRiskRule
******** Transaction Size Per Period Rules ********

*maxSize size must be equal to riskLevel size + 1.
This is because the maxSize should also specified the max tx
size allowed for anything between the highest risk level and 100
which is specified in the last position of the maxSize.
The positionning of the elements within the arrays has meaning.
The first element in the maxSize array corresponds to the risk
range between 0 and the risk score specified in the first position
of the riskLevel array (exclusive). The last maxSize value
will represent the max tx size allowed for any risk score above
the risk level set in the last element of the riskLevel array.
Therefore, the order of the values inside the riskLevel
array must be ascendant.*


```solidity
struct TxSizePerPeriodToRiskRule {
    uint48[] maxSize;
    uint8[] riskLevel;
    uint8 period;
    uint64 startingTime;
}
```

### AccountBalanceToRiskRule
******** Account Balance Rules By Risk Score ********


```solidity
struct AccountBalanceToRiskRule {
    uint8[] riskLevel;
    uint48[] maxBalance;
}
```

