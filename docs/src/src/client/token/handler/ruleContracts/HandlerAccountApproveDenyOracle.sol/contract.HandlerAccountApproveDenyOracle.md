# HandlerAccountApproveDenyOracle
[Git Source](https://github.com/thrackle-io/tron/blob/6347e28a06cfe8dcc416f54eea2d35ee6b0ce9fd/src/client/token/handler/ruleContracts/HandlerAccountApproveDenyOracle.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setAccountApproveDenyOracleId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the accountApproveDenyOracleId. Restricted to rule administrators only.*


```solidity
function setAccountApproveDenyOracleId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountApproveDenyOracle

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountApproveDenyOracle(ActionTypes[] calldata _actions, bool _on, uint32 ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|
|`ruleId`|`uint32`|the id of the rule to activate/deactivate|


### getAccountApproveDenyOracleIds

*Retrieve the account approve deny oracle rule id*


```solidity
function getAccountApproveDenyOracleIds(ActionTypes _action) external view returns (uint32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32[]`|oracleRuleId|


### isAccountAllowDenyOracleActive

*Tells you if the Accont Approve Deny Oracle Rule is active or not.*


```solidity
function isAccountAllowDenyOracleActive(ActionTypes _action, uint32 ruleId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|
|`ruleId`|`uint32`|the id of the rule to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### removeAccountApproveDenyOracle

*Removes an account approve deny oracle rule from the list.*


```solidity
function removeAccountApproveDenyOracle(ActionTypes[] calldata _actions, uint32 ruleId)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|the action types|
|`ruleId`|`uint32`|the id of the rule to remove|


