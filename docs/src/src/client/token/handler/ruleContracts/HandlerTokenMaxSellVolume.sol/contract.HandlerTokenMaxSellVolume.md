# HandlerTokenMaxSellVolume
[Git Source](https://github.com/thrackle-io/tron/blob/5605c9510d83af8a1b2bbbbbe9ac058b9e276ba7/src/client/token/handler/ruleContracts/HandlerTokenMaxSellVolume.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setTokenMaxSellVolumeId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the AccountMaxSellSizeRuleId. Restricted to rule administrators only.*


```solidity
function setTokenMaxSellVolumeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### setTokenMaxSellVolumeIdFull

that setting a rule will automatically activate it.

*Set the TokenMaxSellVolume suite. Restricted to rule administrators only.*


```solidity
function setTokenMaxSellVolumeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearTokenMaxSellVolume

*Clear the rule data structure*


```solidity
function clearTokenMaxSellVolume() internal;
```

### setTokenMaxSellVolumeIdUpdate

that setting a rule will automatically activate it.

*Set the TokenMaxSellVolume.*


```solidity
function setTokenMaxSellVolumeIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTokenMaxSellVolume

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateTokenMaxSellVolume(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getTokenMaxSellVolumeId

*Retrieve the Account Max Sell Size Rule Id*


```solidity
function getTokenMaxSellVolumeId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxSellSizeId|


### isTokenMaxSellVolumeActive

*Tells you if the Account Max Sell Size Rule is active or not.*


```solidity
function isTokenMaxSellVolumeActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


