# HandlerTokenMaxBuyVolume
[Git Source](https://github.com/thrackle-io/tron/blob/f201d50818b608b30301a670e76c0b866af89050/src/client/token/handler/ruleContracts/HandlerTokenMaxBuyVolume.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setTokenMaxBuyVolumeId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the TokenMaxBuyVolume. Restricted to rule administrators only.*


```solidity
function setTokenMaxBuyVolumeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### setTokenMaxBuyVolumeIdFull

after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.

that setting a rule will automatically activate it.

*Set the TokenMaxBuyVolume suite. Restricted to rule administrators only.*


```solidity
function setTokenMaxBuyVolumeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearTokenMaxBuyVolume

*Clear the rule data structure*


```solidity
function clearTokenMaxBuyVolume() internal;
```

### setTokenMaxBuyVolumeIdUpdate

that setting a rule will automatically activate it.

*Set the TokenMaxBuyVolume.*


```solidity
function setTokenMaxBuyVolumeIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTokenMaxBuyVolume

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateTokenMaxBuyVolume(bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getTokenMaxBuyVolumeId

*Retrieve the Account Max Buy Size Rule Id*


```solidity
function getTokenMaxBuyVolumeId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxBuySizeId|


### isTokenMaxBuyVolumeActive

*Tells you if the Account Max Buy Size Rule is active or not.*


```solidity
function isTokenMaxBuyVolumeActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


