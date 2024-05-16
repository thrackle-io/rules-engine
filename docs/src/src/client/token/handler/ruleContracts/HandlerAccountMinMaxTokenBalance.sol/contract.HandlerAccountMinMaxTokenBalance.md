# HandlerAccountMinMaxTokenBalance
[Git Source](https://github.com/thrackle-io/tron/blob/a6e068f4bc8dd6e86015430d874759ac1519196d/src/client/token/handler/ruleContracts/HandlerAccountMinMaxTokenBalance.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ActionTypesArray](/src/client/common/ActionTypesArray.sol/contract.ActionTypesArray.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setAccountMinMaxTokenBalanceId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the accountMinMaxTokenBalanceRuleId. Restricted to rule administrators only.*


```solidity
function setAccountMinMaxTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_ruleId`|`uint32`|Rule Id to set|


### setAccountMinMaxTokenBalanceIdFull

that setting a rule will automatically activate it.

This function does not check that the array length is greater than zero to allow for clearing out of the action types data

*Set the setAccountMinMaxTokenBalanceRule suite. Restricted to rule administrators only.*


```solidity
function setAccountMinMaxTokenBalanceIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearMinMaxTokenBalance

*Clear the rule data structure*


```solidity
function clearMinMaxTokenBalance() internal;
```

### setAccountMinMaxTokenBalanceIdUpdate

that setting a rule will automatically activate it.

*Set the AccountMaxMinMaxTokenBalanceRuleId.*


```solidity
function setAccountMinMaxTokenBalanceIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMinMaxTokenBalance

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMinMaxTokenBalance(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getAccountMinMaxTokenBalanceId

Get the accountMinMaxTokenBalanceRuleId.


```solidity
function getAccountMinMaxTokenBalanceId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMinMaxTokenBalance rule id.|


### isAccountMinMaxTokenBalanceActive

*Tells you if the AccountMinMaxTokenBalance is active or not.*


```solidity
function isAccountMinMaxTokenBalanceActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


