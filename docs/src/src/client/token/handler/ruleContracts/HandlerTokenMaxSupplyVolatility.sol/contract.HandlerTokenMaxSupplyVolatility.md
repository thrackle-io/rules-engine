# HandlerTokenMaxSupplyVolatility
[Git Source](https://github.com/thrackle-io/tron/blob/263e499d66345014a4fa5059735434da59124980/src/client/token/handler/ruleContracts/HandlerTokenMaxSupplyVolatility.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

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
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|totalTokenMaxSupplyVolatilityId rule id|


### setTokenMaxSupplyVolatilityId

that setting a rule will automatically activate it.

*Set the tokenMaxSupplyVolatilityRuleId. Restricted to rule admins only.*


```solidity
function setTokenMaxSupplyVolatilityId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action type|
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


