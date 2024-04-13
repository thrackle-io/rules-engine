# ApplicationAccessLevelProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/3af53b224777c5c1f4e2e734b7757bd798236667/src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol)

**Inherits:**
[IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IAccessLevelErrors](/src/common/IErrors.sol/interface.IAccessLevelErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Access Level Rule Checks. Access Level rules are measured in
in terms of USD with 18 decimals of precision.

*This contract implements rules to be checked by am Application Handler.*


## Functions
### checkAccountMaxValueByAccessLevel

*Check if transaction passes Account Max Value By AccessLevel rule.*


```solidity
function checkAccountMaxValueByAccessLevel(
    uint32 _ruleId,
    uint8 _accessLevel,
    uint128 _balance,
    uint128 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_accessLevel`|`uint8`|the Access Level of the account|
|`_balance`|`uint128`|account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total USD amount to be transferred with 18 decimals of precision|


### getAccountMaxValueByAccessLevel

max has to be multiplied by 10 ** 18 to take decimals in token pricing into account

*Function to get the Account Max Value By Access Level rule in the rule set that belongs to the Access Level*


```solidity
function getAccountMaxValueByAccessLevel(uint32 _index, uint8 _accessLevel) public view returns (uint48);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accessLevel`|`uint8`|AccessLevel Level to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint48`|balanceAmount balance allowed for access level|


### getTotalAccountMaxValueByAccessLevel

*Function to get total Account Max Value By Access Level rules*


```solidity
function getTotalAccountMaxValueByAccessLevel() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkAccountMaxValueOutByAccessLevel

*Check if transaction passes Account Max Value Out By Access Level rule.*


```solidity
function checkAccountMaxValueOutByAccessLevel(
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


### getAccountMaxValueOutByAccessLevel

max has to be multiplied by 10 ** 18 to take decimals in token pricing into account

*Function to get the Account Max Value Out By Access Level rule in the rule set that belongs to the Access Level*


```solidity
function getAccountMaxValueOutByAccessLevel(uint32 _index, uint8 _accessLevel) public view returns (uint48);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accessLevel`|`uint8`|AccessLevel Level to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint48`|balanceAmount balance allowed for access level|


### getTotalAccountMaxValueOutByAccessLevel

*Function to get total Account Max Value Out By Access Level rules*


```solidity
function getTotalAccountMaxValueOutByAccessLevel() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total number of access level withdrawal rules|


### checkAccountDenyForNoAccessLevel

*Check if transaction passes Account Deny For No Access Level rule.This has no stored rule as there are no additional variables needed.*


```solidity
function checkAccountDenyForNoAccessLevel(uint8 _accessLevel) external pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accessLevel`|`uint8`|the Access Level of the account|


