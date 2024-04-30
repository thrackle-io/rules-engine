# HandlerAdminMinTokenBalance
[Git Source](https://github.com/thrackle-io/tron/blob/fa1f71d854feb4f93c1bbe77dbe731527e9e3d00/src/client/token/handler/ruleContracts/HandlerAdminMinTokenBalance.sol)

**Inherits:**
[ActionTypesArray](/src/client/common/ActionTypesArray.sol/contract.ActionTypesArray.md), [IAppManagerErrors](/src/common/IErrors.sol/interface.IAppManagerErrors.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IAdminMinTokenBalanceCapable](/src/client/token/IAdminMinTokenBalanceCapable.sol/abstract.IAdminMinTokenBalanceCapable.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setAdminMinTokenBalanceId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the AdminMinTokenBalance. Restricted to rule administrators only.*


```solidity
function setAdminMinTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
|`_ruleId`|`uint32`|Rule Id to set|


### setAdminMinTokenBalanceIdFull

if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.

that setting a rule will automatically activate it.

*Set the setAdminMinTokenBalance suite. Restricted to rule administrators only.*


```solidity
function setAdminMinTokenBalanceIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearAdminMinTokenBalance

*Clear the rule data structure*


```solidity
function clearAdminMinTokenBalance() internal;
```

### setAdminMinTokenBalanceIdUpdate

that setting a rule will automatically activate it.

*Set the AdminMinTokenBalance.*


```solidity
function setAdminMinTokenBalanceIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### isAdminMinTokenBalanceActiveAndApplicable

*This function is used by the app manager to determine if the AdminMinTokenBalance rule is active for any actions*


```solidity
function isAdminMinTokenBalanceActiveAndApplicable() public view override returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true if all checks pass|


### isAdminMinTokenBalanceActiveForAnyAction

if the rule is active for any actions, set it as active and applicable.

*This function is used internally to check if the admin min token balance is active for any actions*


```solidity
function isAdminMinTokenBalanceActiveForAnyAction() internal view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true if all checks pass|


### activateAdminMinTokenBalance

if the rule is active for any actions, set it as active and applicable.

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAdminMinTokenBalance(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAdminMinTokenBalanceActive

if the rule is currently active, we check that time for current ruleId is expired

*Tells you if the admin min token balance rule is active or not.*


```solidity
function isAdminMinTokenBalanceActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAdminMinTokenBalanceId

*Retrieve the admin min token balance rule id*


```solidity
function getAdminMinTokenBalanceId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminMinTokenBalanceRuleId rule id|


