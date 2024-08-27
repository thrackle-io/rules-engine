# HandlerTokenMinTxSize
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0775549ba2fe667ec66be14a19fcc8b784774a43/src/client/token/handler/ruleContracts/HandlerTokenMinTxSize.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ActionTypesArray](/src/client/common/ActionTypesArray.sol/contract.ActionTypesArray.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setTokenMinTxSizeId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the TokenMinTxSize. Restricted to rule administrators only.*


```solidity
function setTokenMinTxSizeId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_ruleId`|`uint32`|Rule Id to set|


### setTokenMinTxSizeIdFull

that setting a rule will automatically activate it.

This function does not check that the array length is greater than zero to allow for clearing out of the action types data

*Set the setTokenMinTxSizeRule suite. Restricted to rule administrators only.*


```solidity
function setTokenMinTxSizeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearTokenMinTxSize

*Clear the rule data structure*


```solidity
function clearTokenMinTxSize() internal;
```

### setTokenMinTxSizeIdUpdate

that setting a rule will automatically activate it.

*Set the TokenMinTxSize.*


```solidity
function setTokenMinTxSizeIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTokenMinTxSize

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateTokenMinTxSize(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getTokenMinTxSizeId

*Retrieve the tokenMinTxSizeRuleId*


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


