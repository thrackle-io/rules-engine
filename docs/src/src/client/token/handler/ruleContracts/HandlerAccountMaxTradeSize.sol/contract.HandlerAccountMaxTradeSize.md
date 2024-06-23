# HandlerAccountMaxTradeSize
[Git Source](https://github.com/thrackle-io/tron/blob/5b7fc1e99a9efe7cd4509a3bd8aa91769d651104/src/client/token/handler/ruleContracts/HandlerAccountMaxTradeSize.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ActionTypesArray](/src/client/common/ActionTypesArray.sol/contract.ActionTypesArray.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### getAccountMaxTradeSizeId

Rule Setters and Getters

*Retrieve the Account Max Trade Size Rule Id*


```solidity
function getAccountMaxTradeSizeId(ActionTypes _actions) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes`|the action types|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxTradeSizeId|


### setAccountMaxTradeSizeId

that setting a rule will automatically activate it.

*Set the AccountMaxTradeSizeRuleId. Restricted to rule administrators only.*


```solidity
function setAccountMaxTradeSizeId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_ruleId`|`uint32`|Rule Id to set|


### setAccountMaxTradeSizeIdFull

that setting a rule will automatically activate it.

This function does not check that the array length is greater than zero to allow for clearing out of the action types data

*Set the AccountMaxTradeSizeRule suite. Restricted to rule administrators only.*


```solidity
function setAccountMaxTradeSizeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearAccountMaxTradeSize

*Clear the rule data structure*


```solidity
function clearAccountMaxTradeSize() internal;
```

### setAccountMaxTradeSizeIdUpdate

that setting a rule will automatically activate it.

*Set the AccountMaxTradeSizeRuleId.*


```solidity
function setAccountMaxTradeSizeIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### resetAccountMaxTradeSize

*reset the ruleChangeDate within the rule data struct. This will signal the rule check to clear the accumulator data prior to checking the rule.*


```solidity
function resetAccountMaxTradeSize() internal;
```

### activateAccountMaxTradeSize

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxTradeSize(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type to set the rule|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxTradeSizeActive

*Tells you if the Account Max Trade Size Rule is active or not.*


```solidity
function isAccountMaxTradeSizeActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


