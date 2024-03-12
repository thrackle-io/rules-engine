# HandlerTokenMaxBuyVolume
[Git Source](https://github.com/thrackle-io/tron/blob/b7e3c80b9894bc0c1005dc8b0adb631c487f2598/src/client/token/handler/ruleContracts/HandlerTokenMaxBuyVolume.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setTokenMaxBuyVolumeId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the TokenMaxBuyVolumeRuleId. Restricted to rule administrators only.*


```solidity
function setTokenMaxBuyVolumeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
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


