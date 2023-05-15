# FeeRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/economic/ruleProcessor/nontagged/FeeRuleProcessorFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Token Fee Rules on Accounts.

*Facet in charge of the logic to check fee rule compliance*


## Functions
### assessAMMFee

*Assess the fee associated with the AMM Fee Rule*


```solidity
function assessAMMFee(uint32 _ruleId, uint256 _collateralizedTokenAmount) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_collateralizedTokenAmount`|`uint256`|total number of collateralized tokens to be swapped(this could be the "token in" or "token out" as the fees are always * assessed from the collateralized token)|


## Errors
### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

