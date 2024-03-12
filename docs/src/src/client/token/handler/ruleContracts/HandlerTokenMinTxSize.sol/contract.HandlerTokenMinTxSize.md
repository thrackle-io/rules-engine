# HandlerTokenMinTxSize
[Git Source](https://github.com/thrackle-io/tron/blob/a1ed7a1196c8d6c5b62fc72c2a02c192f6b90700/src/client/token/handler/ruleContracts/HandlerTokenMinTxSize.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setTokenMinTxSizeId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the tokenMinTransactionRuleId. Restricted to rule administrators only.*


```solidity
function setTokenMinTxSizeId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
|`_ruleId`|`uint32`|Rule Id to set|


### activateMinTransactionSizeRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateMinTransactionSizeRule(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getTokenMinTxSizeId

*Retrieve the tokenMinTransactionRuleId*


```solidity
function getTokenMinTxSizeId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|tokenMinTransactionRuleId|


### isTokenMinTxSizeActive

*Tells you if the TokenMinTxSizeRule is active or not.*


```solidity
function isTokenMinTxSizeActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


