# HandlerAccountApproveDenyOracle
[Git Source](https://github.com/thrackle-io/tron/blob/cbc87814d6bed0b3e71e8ab959486c532d05c771/src/client/token/handler/ruleContracts/HandlerAccountApproveDenyOracle.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [ActionTypesArray](/src/client/common/ActionTypesArray.sol/contract.ActionTypesArray.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/common/IErrors.sol/interface.IAssetHandlerErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setAccountApproveDenyOracleId

Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the AccountApproveDenyOracle. Restricted to rule administrators only.*


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


### setAccountApproveDenyOracleIdFull

that setting a rule will automatically activate it.

*Set the setAccountMinMaxTokenBalanceRule suite. This function works differently since the rule allows multiples per action. The actions are repeated to account for multiple oracle rules per action. Restricted to rule administrators only.*


```solidity
function setAccountApproveDenyOracleIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearAccountApproveDenyOracle

*Clear the rule data structure*


```solidity
function clearAccountApproveDenyOracle() internal;
```

### setAccountApproveDenyOracleIdUpdate

that setting a rule will automatically activate it.

*Set the AccountApproveDenyOracle.*


```solidity
function setAccountApproveDenyOracleIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### _doesAccountApproveDenyOracleIdExist

*Check to see if the oracle rule already exists in the array. If it does, return the index*


```solidity
function _doesAccountApproveDenyOracleIdExist(ActionTypes _action, uint32 _ruleId)
    internal
    view
    returns (uint256 _index, bool _found);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the corresponding action|
|`_ruleId`|`uint32`|the rule's identifier|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint256`|the index of the found oracle rule|
|`_found`|`bool`|true if found|


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


### isAccountApproveDenyOracleActive

*Tells you if the Accont Approve Deny Oracle Rule is active or not.*


```solidity
function isAccountApproveDenyOracleActive(ActionTypes _action, uint32 ruleId) external view returns (bool);
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


