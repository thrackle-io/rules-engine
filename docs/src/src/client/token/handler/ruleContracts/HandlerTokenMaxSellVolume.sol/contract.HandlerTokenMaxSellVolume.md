# HandlerTokenMaxSellVolume
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/client/token/handler/ruleContracts/HandlerTokenMaxSellVolume.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setTokenMaxSellVolumeId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the TokenMaxSellVolumeRuleId. Restricted to rule administrators only.*


```solidity
function setTokenMaxSellVolumeId(uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
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


