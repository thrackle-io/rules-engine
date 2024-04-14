# HandlerTokenMaxBuySellVolume
[Git Source](https://github.com/thrackle-io/tron/blob/87ff5b38c590a4edb91556fd9ab3428df36445b8/src/client/token/handler/ruleContracts/HandlerTokenMaxBuySellVolume.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ActionTypesArray](/src/client/common/ActionTypesArray.sol/contract.ActionTypesArray.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### getTokenMaxBuySellVolumeId

Rule Setters and Getters

*Retrieve the Account Max Buy Sell Size Rule Id*


```solidity
function getTokenMaxBuySellVolumeId(ActionTypes _actions) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes`|the action types|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxBuySellSizeId|


### setTokenMaxBuySellVolumeId

that setting a rule will automatically activate it.

*Set the TokenMaxBuySellVolume. Restricted to rule administrators only.*


```solidity
function setTokenMaxBuySellVolumeId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_ruleId`|`uint32`|Rule Id to set|


### setTokenMaxBuySellVolumeIdFull

that setting a rule will automatically activate it.

*Set the TokenMaxBuySellVolume suite. Restricted to rule administrators only.*


```solidity
function setTokenMaxBuySellVolumeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearTokenMaxBuySellVolume

*Clear the rule data structure*


```solidity
function clearTokenMaxBuySellVolume() internal;
```

### setTokenMaxBuySellVolumeIdUpdate

that setting a rule will automatically activate it.

*Set the TokenMaxBuySellVolume.*


```solidity
function setTokenMaxBuySellVolumeIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTokenMaxBuySellVolume

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateTokenMaxBuySellVolume(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type to set the rule|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isTokenMaxBuySellVolumeActive

*Tells you if the Account Max Buy Sell Size Rule is active or not.*


```solidity
function isTokenMaxBuySellVolumeActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


