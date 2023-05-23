# ApplicationAccessLevelProcessorFacet
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/economic/ruleProcessor/nontagged/ApplicationAccessLevelProcessorFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements AccessLevel Rule Checks on Tagged Accounts. AccessLevel rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by Handler.*


## Functions
### checkBalanceByAccessLevelPasses

*Check if transaction passes Balance by AccessLevel rule.*


```solidity
function checkBalanceByAccessLevelPasses(
    uint32 _ruleId,
    uint8 _accessLevel,
    uint256 _balance,
    uint256 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_accessLevel`|`uint8`|the Access Level of the account|
|`_balance`|`uint256`|account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint256`|total USD amount to be transferred with 18 decimals of precision|


### checkAccessLevel0Passes

Get the account's AccessLevel Level
max has to be multiplied by 10 ** 18 to take decimals in token pricing into account

*Check if transaction passes AccessLevel 0 rule.This has no stored rule as there are no additional variables needed.*


```solidity
function checkAccessLevel0Passes(uint8 _accessLevel) external pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accessLevel`|`uint8`|the Access Level of the account|


## Errors
### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

### BalanceExceedsAccessLevelAllowedLimit

```solidity
error BalanceExceedsAccessLevelAllowedLimit();
```

### NotAllowedForAccessLevel

```solidity
error NotAllowedForAccessLevel();
```

