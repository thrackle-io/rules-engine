# ApplicationAccessLevelProcessorFacet
<<<<<<< HEAD
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol)
=======
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol)
>>>>>>> external

**Inherits:**
[IRuleProcessorErrors](/src/interfaces/IErrors.sol/interface.IRuleProcessorErrors.md), [IAccessLevelErrors](/src/interfaces/IErrors.sol/interface.IAccessLevelErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements AccessLevel Rule Checks. AccessLevel rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by Handler.*


## Functions
### checkAccBalanceByAccessLevel

*Check if transaction passes Balance by AccessLevel rule.*


```solidity
function checkAccBalanceByAccessLevel(uint32 _ruleId, uint8 _accessLevel, uint128 _balance, uint128 _amountToTransfer)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_accessLevel`|`uint8`|the Access Level of the account|
|`_balance`|`uint128`|account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total USD amount to be transferred with 18 decimals of precision|


### checkwithdrawalLimitsByAccessLevel

Get the account's AccessLevel
max has to be multiplied by 10 ** 18 to take decimals in token pricing into account

*Check if transaction passes Withdrawal by AccessLevel rule.*


```solidity
function checkwithdrawalLimitsByAccessLevel(
    uint32 _ruleId,
    uint8 _accessLevel,
    uint128 _usdWithdrawalTotal,
    uint128 _usdAmountTransferring
) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_accessLevel`|`uint8`|the Access Level of the account|
|`_usdWithdrawalTotal`|`uint128`|account's total amount withdrawn in USD with 18 decimals of precision|
|`_usdAmountTransferring`|`uint128`|total USD amount to be transferred with 18 decimals of precision|


### checkAccessLevel0Passes

max has to be multiplied by 10 ** 18 to take decimals in token pricing into account

*Check if transaction passes AccessLevel 0 rule.This has no stored rule as there are no additional variables needed.*


```solidity
function checkAccessLevel0Passes(uint8 _accessLevel) external pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accessLevel`|`uint8`|the Access Level of the account|


