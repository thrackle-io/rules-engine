# HandlerTokenMaxSupplyVolatility
[Git Source](https://github.com/thrackle-io/tron/blob/a32755ef70ede3dfc3a49e226e4b15ac07a36ebd/src/client/token/handler/ruleContracts/HandlerTokenMaxSupplyVolatility.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ActionTypesArray](/src/client/common/ActionTypesArray.sol/contract.ActionTypesArray.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### getTokenMaxSupplyVolatilityId

Rule Setters and Getters

*Retrieve the token max supply volatility rule id*


```solidity
function getTokenMaxSupplyVolatilityId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type(this left in to keep signatures the same for dependent apis)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|totalTokenMaxSupplyVolatilityId rule id|


### setTokenMaxSupplyVolatilityId

that setting a rule will automatically activate it.

*Set the TokenMaxSupplyVolatility. Restricted to rule administrators only.*


```solidity
function setTokenMaxSupplyVolatilityId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_ruleId`|`uint32`|Rule Id to set|


### clearTokenMaxSupplyVolatility

*Clear the rule data structure*


```solidity
function clearTokenMaxSupplyVolatility() internal;
```

### setTokenMaxSupplyVolatilityIdUpdate

that setting a rule will automatically activate it.

*Set the TokenMaxSupplyVolatility.*


```solidity
function setTokenMaxSupplyVolatilityIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTokenMaxSupplyVolatility

*Tells you if the Token Max Supply Volatility rule is active or not.*


```solidity
function activateTokenMaxSupplyVolatility(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
|`_on`|`bool`|boolean representing if the rule is active|


### isTokenMaxSupplyVolatilityActive

*Tells you if the Token Max Supply Volatility is active or not.*


```solidity
function isTokenMaxSupplyVolatilityActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


