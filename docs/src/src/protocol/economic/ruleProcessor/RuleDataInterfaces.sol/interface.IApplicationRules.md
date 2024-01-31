# IApplicationRules
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)


## Structs
### AccountMaxTransactionValueByRiskScore
******** Transaction Size Per Period Rules ********

*maxSize size must be equal to riskScore size + 1.
This is because the maxSize should also specified the max tx
size allowed for anything between the highest risk level and 100
which is specified in the last position of the maxSize.
The positionning of the elements within the arrays has meaning.
The first element in the maxSize array corresponds to the risk
range between 0 and the risk score specified in the first position
of the riskScore array (exclusive). The last maxSize value
will represent the max tx size allowed for any risk score above
the risk level set in the last element of the riskScore array.
Therefore, the order of the values inside the riskScore
array must be ascendant.*


```solidity
struct AccountMaxTransactionValueByRiskScore {
    uint48[] maxSize;
    uint8[] riskScore;
    uint16 period;
    uint64 startingTime;
}
```

### AccountMaxValueByRiskScore
******** Account Balance Rules By Risk Score ********


```solidity
struct AccountMaxValueByRiskScore {
    uint8[] riskScore;
    uint48[] maxBalance;
}
```

