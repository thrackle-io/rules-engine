# HandlerTokenMinHoldTime
[Git Source](https://github.com/thrackle-io/tron/blob/1a1d6b2809bc510780a53bad6853fa1ef1652aab/src/client/token/handler/ruleContracts/HandlerTokenMinHoldTime.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## State Variables
### MAX_HOLD_TIME_HOURS

```solidity
uint16 constant MAX_HOLD_TIME_HOURS = 43830;
```


## Functions
### activateTokenMinHoldTime

-------------SIMPLE RULE SETTERS and GETTERS---------------

*Tells you if the minimum hold time rule is active or not.*


```solidity
function activateTokenMinHoldTime(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
|`_on`|`bool`|boolean representing if the rule is active|


### setTokenMinHoldTime

*Setter the minimum hold time rule hold hours*


```solidity
function setTokenMinHoldTime(ActionTypes[] calldata _actions, uint32 _minHoldTimeHours)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_minHoldTimeHours`|`uint32`|minimum amount of time to hold the asset|


### getTokenMinHoldTimePeriod

*Get the minimum hold time rule hold hours*


```solidity
function getTokenMinHoldTimePeriod(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|period minimum amount of time to hold the asset|


### isTokenMinHoldTimeActive

*function to check if Minumum Hold Time is active*


```solidity
function isTokenMinHoldTimeActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


