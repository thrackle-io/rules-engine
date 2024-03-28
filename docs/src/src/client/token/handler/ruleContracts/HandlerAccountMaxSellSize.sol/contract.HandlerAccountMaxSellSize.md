# HandlerAccountMaxSellSize
[Git Source](https://github.com/thrackle-io/tron/blob/a0f5ead5c8fc9d4614336dc446184e42c1f4b0fa/src/client/token/handler/ruleContracts/HandlerAccountMaxSellSize.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setAccountMaxSellSizeId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the AccountMaxSellSizeRuleId. Restricted to rule administrators only.*


```solidity
function setAccountMaxSellSizeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### setAccountMaxSellSizeIdFull

that setting a rule will automatically activate it.

*Set the AccountMaxSellSizeRule suite. Restricted to rule administrators only.*


```solidity
function setAccountMaxSellSizeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearAccountMaxSellSize

*Clear the rule data structure*


```solidity
function clearAccountMaxSellSize() internal;
```

### setAccountMaxSellSizeIdUpdate

that setting a rule will automatically activate it.

*Set the AccountMaxSellSizeRuleId.*


```solidity
function setAccountMaxSellSizeIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxSellSize

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxSellSize(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getAccountMaxSellSizeId

*Retrieve the Account Max Sell Size Rule Id*


```solidity
function getAccountMaxSellSizeId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxSellSizeId|


### isAccountMaxSellSizeActive

*Tells you if the Account Max Sell Size Rule is active or not.*


```solidity
function isAccountMaxSellSizeActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


