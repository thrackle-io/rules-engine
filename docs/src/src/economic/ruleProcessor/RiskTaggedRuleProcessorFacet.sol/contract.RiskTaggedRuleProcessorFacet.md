# RiskTaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/9adfea3f253340fbb4af30cdc0009d491b72e160/src/economic/ruleProcessor/RiskTaggedRuleProcessorFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Risk Rules on Tagged Accounts. All risk rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by Handler.*


## Functions
### checkTransactionLimitByRiskScore

*Transaction Limit for Risk Score*


```solidity
function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_riskScore`|`uint8`|the Risk Score of the account|
|`_amountToTransfer`|`uint256`|total USD amount to be transferred with 18 decimals of precision|


## Errors
### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

### MaxTxSizePerPeriodReached

```solidity
error MaxTxSizePerPeriodReached(uint8 riskScore, uint256 maxTxSize, uint8 hoursOfPeriod);
```

### TransactionExceedsRiskScoreLimit

```solidity
error TransactionExceedsRiskScoreLimit();
```

### BalanceExceedsRiskScoreLimit

```solidity
error BalanceExceedsRiskScoreLimit();
```

