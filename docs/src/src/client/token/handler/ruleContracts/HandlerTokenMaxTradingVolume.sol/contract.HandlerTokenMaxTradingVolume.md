# HandlerTokenMaxTradingVolume
[Git Source](https://github.com/thrackle-io/tron/blob/d9139140f50076b996b790d1128c5e2182de1d13/src/client/token/handler/ruleContracts/HandlerTokenMaxTradingVolume.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### getTokenMaxTradingVolumeId

Rule Setters and Getters

*Retrieve the token max trading volume rule id*


```solidity
function getTokenMaxTradingVolumeId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|tokenMaxTradingVolumeRuleId rule id|


### setTokenMaxTradingVolumeId

that setting a rule will automatically activate it.

*Set the TokenMaxTradingVolume. Restricted to rule administrators only.*


```solidity
function setTokenMaxTradingVolumeId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_ruleId`|`uint32`|Rule Id to set|


### setTokenMaxTradingVolumeIdFull

that setting a rule will automatically activate it.

*Set the setAccountMinMaxTokenBalanceRule suite. Restricted to rule administrators only.*


```solidity
function setTokenMaxTradingVolumeIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearTokenMaxTradingVolume

*Clear the rule data structure*


```solidity
function clearTokenMaxTradingVolume() internal;
```

### setTokenMaxTradingVolumeIdUpdate

that setting a rule will automatically activate it.

*Set the TokenMaxTradingVolume.*


```solidity
function setTokenMaxTradingVolumeIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTokenMaxTradingVolume

*Tells you if the token max trading volume rule is active or not.*


```solidity
function activateTokenMaxTradingVolume(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
|`_on`|`bool`|boolean representing if the rule is active|


### isTokenMaxTradingVolumeActive

*Tells you if the token max trading volume rule is active or not.*


```solidity
function isTokenMaxTradingVolumeActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


