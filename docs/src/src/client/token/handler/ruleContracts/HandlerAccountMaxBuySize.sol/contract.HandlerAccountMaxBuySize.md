# HandlerAccountMaxBuySize
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/client/token/handler/ruleContracts/HandlerAccountMaxBuySize.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setAccountMaxBuySizeId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the AccountMaxBuySizeRuleId. Restricted to rule administrators only.*


```solidity
function setAccountMaxBuySizeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxBuySize

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxBuySize(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getAccountMaxBuySizeId

*Retrieve the Account Max Buy Size Rule Id*


```solidity
function getAccountMaxBuySizeId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxBuySizeId|


### isAccountMaxBuySizeActive

*Tells you if the Account Max Buy Size Rule is active or not.*


```solidity
function isAccountMaxBuySizeActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


